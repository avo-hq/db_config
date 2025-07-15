require "db_config/version"
require "db_config/railtie"
require "db_config/config_record"
require "json"

module DBConfig
  class NotFoundError < StandardError; end

  # Private sentinel object to detect when no default is provided
  NO_DEFAULT_PROVIDED = Object.new.freeze
  
  class << self
    def get(key, default: NO_DEFAULT_PROVIDED)
      record = DBConfig::ConfigRecord.find_by(key: key.to_s)
      
      if record
        convert_value(record.value, record.value_type)
      elsif default != NO_DEFAULT_PROVIDED
        # Create the key with the default value if not found and default is provided
        # This allows nil to be a valid default value
        set(key, default)
      else
        raise NotFoundError, "DBConfig not found for key: #{key}"
      end
    end

    def set(key, value)
      key_str = key.to_s
      value_str = serialize_value(value)
      value_type = determine_type(value)

      record = DBConfig::ConfigRecord.find_or_initialize_by(key: key_str)
      record.update!(
        value: value_str,
        value_type: value_type,
        eager_load: record.eager_load || false
      )

      convert_value(record.value, record.value_type)
    end

    def eager_load(key, enabled)
      record = DBConfig::ConfigRecord.find_by(key: key.to_s)
      raise NotFoundError, "DBConfig not found for key: #{key}" unless record

      record.update!(eager_load: enabled)
      enabled
    end

    private

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
