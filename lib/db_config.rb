require "db_config/version"
require "db_config/railtie"
require "db_config/config_record"
require "db_config/current"
require "json"

module DBConfig
  class NotFoundError < StandardError; end

  class << self
    def get(key)
      record = get_record(key)
      record ? convert_value(record.value, record.value_type) : nil
    end

    def get!(key)
      record = get_record(key)

      if record
        convert_value(record.value, record.value_type)
      else
        raise NotFoundError, "DBConfig not found for key: #{key}"
      end
    end

    def set(key, value)
      value_str = serialize_value(value)
      value_type = determine_type(value)
      key = key.to_s

      record = Current.cached_records[key] || DBConfig::ConfigRecord.find_or_initialize_by(key:)

      record.update!(
        value: value_str,
        value_type: value_type,
        eager_load: record.eager_load || false
      )

      convert_value(record.value, record.value_type)
    end

    def delete(key)
      key_str = key.to_s
      record = DBConfig::ConfigRecord.find_by(key: key_str)

      if record
        record.destroy!
        true
      else
        false
      end
    end

    def update(key, **kwargs)
      key_str = key.to_s
      record = get_record(key_str)
      raise NotFoundError, "DBConfig not found for key: #{key}" unless record

      # Extract current values
      current_value = convert_value(record.value, record.value_type)
      current_type = record.value_type

      # Process updates
      updates = {}

      # Handle value update - new values can change type freely
      if kwargs.key?(:value)
        new_value = kwargs[:value]
        new_type = determine_type(new_value)

        updates[:value] = serialize_value(new_value)
        updates[:value_type] = new_type
      end

      # Handle type update with compatibility check
      if kwargs.key?(:type)
        target_type = kwargs[:type]

        # Validate target type
        unless %w[String Integer Float Boolean Array Hash NilClass].include?(target_type)
          raise ArgumentError, "Invalid type: #{target_type}. Must be one of: String, Integer, Float, Boolean, Array, Hash, NilClass"
        end

        # Check if current value can be converted to target type
        unless value_convertible_to_type?(current_value, current_type, target_type)
          raise ArgumentError, "Can't modify type because value \"#{current_value}\" doesn't support conversion from \"#{current_type}\" to \"#{target_type}\""
        end

        # Convert value to new type
        converted_value = convert_value_to_type(current_value, current_type, target_type)
        updates[:value] = serialize_value(converted_value)
        updates[:value_type] = target_type
      end

      # Handle eager_load update
      if kwargs.key?(:eager_load)
        updates[:eager_load] = kwargs[:eager_load]
      end

      # Apply updates
      record.update!(updates)

      # Return the updated value in its new type
      convert_value(record.value, record.value_type)
    end

    def exist?(key)
      get_record(key) != nil
    end

    def fetch(key, &block)
      record = get_record(key)

      if record
        convert_value(record.value, record.value_type)
      elsif block_given?
        # Execute block and store the result
        value = yield
        set(key, value)
      end

      # Return nil if key doesn't exist and no block given
    end

    # Aliases for convenience
    alias_method :read, :get
    alias_method :write, :set

    private

    # Get record from cache or database, returns nil if not found
    def get_record(key)
      key = key.to_s

      Current.cached_records[key] || DBConfig::ConfigRecord.find_by(key:)
    end

    def determine_type(value)
      case value
      when NilClass
        "NilClass"
      when String
        "String"
      when Integer
        "Integer"
      when Float
        "Float"
      when TrueClass, FalseClass
        "Boolean"
      when Array
        "Array"
      when Hash
        "Hash"
      else
        "String"
      end
    end

    def serialize_value(value)
      case value
      when NilClass
        nil
      when Array, Hash
        JSON.generate(value)
      else
        value.to_s
      end
    end

    def convert_value(value_str, value_type)
      case value_type
      when "NilClass"
        nil
      when "Boolean"
        value_str == "true"
      when "Integer"
        value_str.to_i
      when "Float"
        value_str.to_f
      when "Array"
        JSON.parse(value_str)
      when "Hash"
        JSON.parse(value_str)
      else
        value_str
      end
    end

    def types_compatible?(current_value, current_type, new_value, new_type)
      # If types are the same, always compatible
      return true if current_type == new_type

      # Allow specific compatible conversions
      case [current_type, new_type]
      when ["Boolean", "String"], ["Integer", "String"], ["Float", "String"], ["NilClass", "String"]
        true
      when ["String", "Boolean"]
        ["true", "false"].include?(current_value.to_s.downcase)
      when ["String", "Integer"]
        current_value.to_s.match?(/\A-?\d+\z/)
      when ["String", "Float"]
        current_value.to_s.match?(/\A-?\d*\.?\d+\z/)
      when ["Integer", "Float"]
        true
      when ["Float", "Integer"]
        current_value.to_f % 1 == 0  # Only if float is a whole number
      when ["Boolean", "Integer"]
        true  # true -> 1, false -> 0
      when ["Integer", "Boolean"]
        [0, 1].include?(current_value)
      else
        false
      end
    end

    def value_convertible_to_type?(value, current_type, target_type)
      # If types are the same, always convertible
      return true if current_type == target_type

      case target_type
      when "String"
        true  # Everything can be converted to string
      when "Boolean"
        case current_type
        when "String"
          ["true", "false", "1", "0"].include?(value.to_s.downcase)
        when "Integer"
          [0, 1].include?(value)
        else
          false
        end
      when "Integer"
        case current_type
        when "String"
          value.to_s.match?(/\A-?\d+\z/)
        when "Float"
          value.to_f % 1 == 0
        when "Boolean"
          true
        else
          false
        end
      when "Float"
        case current_type
        when "String"
          value.to_s.match?(/\A-?\d*\.?\d+\z/)
        when "Integer", "Boolean"
          true
        else
          false
        end
      else
        false  # Array, Hash, NilClass conversions not supported
      end
    end

    def convert_value_to_type(value, current_type, target_type)
      return value if current_type == target_type

      case target_type
      when "String"
        value.to_s
      when "Boolean"
        case current_type
        when "String"
          ["true", "1"].include?(value.to_s.downcase)
        when "Integer"
          value == 1
        end
      when "Integer"
        case current_type
        when "String"
          value.to_i
        when "Float"
          value.to_i
        when "Boolean"
          value ? 1 : 0
        end
      when "Float"
        case current_type
        when "String"
          value.to_f
        when "Integer"
          value.to_f
        when "Boolean"
          value ? 1.0 : 0.0
        end
      else
        raise ArgumentError, "Conversion to #{target_type} not supported"
      end
    end
  end
end
