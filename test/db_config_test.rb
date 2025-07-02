require "test_helper"

class DBConfigTest < ActiveSupport::TestCase
  def setup
    # Clean up any existing test data
    DBConfig::ConfigRecord.delete_all if defined?(DBConfig::ConfigRecord)
  end

  test "it has a version number" do
    assert DBConfig::VERSION
  end

  test "raises NotFoundError when getting non-existent key" do
    assert_raises(DBConfig::NotFoundError) do
      DBConfig.get(:non_existent_key)
    end
  end

  test "can set and get string values" do
    DBConfig.set(:test_key, "test_value")
    assert_equal "test_value", DBConfig.get(:test_key)
  end

  test "can set and get integer values" do
    DBConfig.set(:int_key, 42)
    assert_equal 42, DBConfig.get(:int_key)
  end

  test "can set and get boolean values" do
    DBConfig.set(:bool_key, true)
    assert_equal true, DBConfig.get(:bool_key)

    DBConfig.set(:false_key, false)
    assert_equal false, DBConfig.get(:false_key)
  end

  test "can set and get float values" do
    DBConfig.set(:float_key, 3.14)
    assert_equal 3.14, DBConfig.get(:float_key)
  end

  test "can set and get array values" do
    test_array = ["item1", "item2", 42, true]
    DBConfig.set(:array_key, test_array)
    assert_equal test_array, DBConfig.get(:array_key)
  end

  test "can set and get hash values" do
    test_hash = {"name" => "John", "age" => 30, "active" => true}
    DBConfig.set(:hash_key, test_hash)
    assert_equal test_hash, DBConfig.get(:hash_key)
  end

  test "can set and get nested hash values" do
    nested_hash = {
      "user" => {
        "profile" => {
          "name" => "Jane",
          "settings" => ["email", "sms"]
        }
      }
    }
    DBConfig.set(:nested_key, nested_hash)
    assert_equal nested_hash, DBConfig.get(:nested_key)
  end

  test "can set and get array of hashes" do
    array_of_hashes = [
      {"id" => 1, "name" => "Alice"},
      {"id" => 2, "name" => "Bob"}
    ]
    DBConfig.set(:users_key, array_of_hashes)
    assert_equal array_of_hashes, DBConfig.get(:users_key)
  end

  test "can update existing values" do
    DBConfig.set(:update_key, "original")
    assert_equal "original", DBConfig.get(:update_key)

    DBConfig.set(:update_key, "updated")
    assert_equal "updated", DBConfig.get(:update_key)
  end

  test "can set eager_load flag" do
    DBConfig.set(:eager_key, "value")

    result = DBConfig.eager_load(:eager_key, true)
    assert_equal true, result

    record = DBConfig::ConfigRecord.find_by(key: "eager_key")
    assert_equal true, record.eager_load
  end

  test "eager_load raises error for non-existent key" do
    assert_raises(DBConfig::NotFoundError) do
      DBConfig.eager_load(:non_existent, true)
    end
  end

  test "preserves eager_load flag when updating value" do
    DBConfig.set(:preserve_key, "value")
    DBConfig.eager_load(:preserve_key, true)

    DBConfig.set(:preserve_key, "new_value")

    record = DBConfig::ConfigRecord.find_by(key: "preserve_key")
    assert_equal true, record.eager_load
    assert_equal "new_value", DBConfig.get(:preserve_key)
  end

  test "works with symbol and string keys" do
    DBConfig.set(:symbol_key, "value")
    assert_equal "value", DBConfig.get("symbol_key")
    assert_equal "value", DBConfig.get(:symbol_key)
  end

  test "stores correct value_type for different data types" do
    DBConfig.set(:string_type, "hello")
    DBConfig.set(:int_type, 123)
    DBConfig.set(:float_type, 1.23)
    DBConfig.set(:bool_type, true)
    DBConfig.set(:array_type, [1, 2, 3])
    DBConfig.set(:hash_type, {"key" => "value"})

    assert_equal "String", DBConfig::ConfigRecord.find_by(key: "string_type").value_type
    assert_equal "Integer", DBConfig::ConfigRecord.find_by(key: "int_type").value_type
    assert_equal "Float", DBConfig::ConfigRecord.find_by(key: "float_type").value_type
    assert_equal "Boolean", DBConfig::ConfigRecord.find_by(key: "bool_type").value_type
    assert_equal "Array", DBConfig::ConfigRecord.find_by(key: "array_type").value_type
    assert_equal "Hash", DBConfig::ConfigRecord.find_by(key: "hash_type").value_type
  end
end
