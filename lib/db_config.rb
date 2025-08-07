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

    def eager_load(key, enabled)
      record = get_record(key)
      raise NotFoundError, "DBConfig not found for key: #{key}" unless record

      record.update!(eager_load: enabled)

      enabled
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
  end
end
