require "test_helper"

class DBConfigTest < ActiveSupport::TestCase
  def setup
    # Clean up any existing test data
    DBConfig::ConfigRecord.delete_all if defined?(DBConfig::ConfigRecord)
  end

  test "it has a version number" do
    assert DBConfig::VERSION
  end

  test "raises NotFoundError when getting non-existent key without default" do
    assert_raises(DBConfig::NotFoundError) do
      DBConfig.get(:non_existent_key)
    end
  end

  test "returns and creates default value when key doesn't exist" do
    # Key doesn't exist yet
    assert_raises(DBConfig::NotFoundError) do
      DBConfig.get(:default_test)
    end

    # Get with default should create and return the default
    result = DBConfig.get(:default_test, default: "default_value")
    assert_equal "default_value", result

    # Key should now exist with the default value
    assert_equal "default_value", DBConfig.get(:default_test)

    # Verify it was actually saved to database
    record = DBConfig::ConfigRecord.find_by(key: "default_test")
    assert_not_nil record
    assert_equal "default_value", record.value
    assert_equal "String", record.value_type
  end

  test "returns existing value when key exists and default is provided" do
    # Set a value first
    DBConfig.set(:existing_key, "existing_value")

    # Get with default should return existing value, not default
    result = DBConfig.get(:existing_key, default: "default_value")
    assert_equal "existing_value", result

    # Verify the value wasn't changed
    assert_equal "existing_value", DBConfig.get(:existing_key)
  end

  test "creates default with different data types" do
    # Integer default
    result = DBConfig.get(:int_default, default: 42)
    assert_equal 42, result
    assert_equal "Integer", DBConfig::ConfigRecord.find_by(key: "int_default").value_type

    # Boolean default
    result = DBConfig.get(:bool_default, default: true)
    assert_equal true, result
    assert_equal "Boolean", DBConfig::ConfigRecord.find_by(key: "bool_default").value_type

    # Array default
    result = DBConfig.get(:array_default, default: [1, 2, 3])
    assert_equal [1, 2, 3], result
    assert_equal "Array", DBConfig::ConfigRecord.find_by(key: "array_default").value_type

    # Hash default
    result = DBConfig.get(:hash_default, default: {"key" => "value"})
    assert_equal({"key" => "value"}, result)
    assert_equal "Hash", DBConfig::ConfigRecord.find_by(key: "hash_default").value_type
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

  test "preserves eager_load flag when getting with default" do
    # Create a key with eager_load enabled
    DBConfig.set(:eager_default_key, "original")
    DBConfig.eager_load(:eager_default_key, true)

    # Delete the record to test default creation
    DBConfig::ConfigRecord.find_by(key: "eager_default_key").destroy

    # Get with default should create new record with default eager_load (false)
    result = DBConfig.get(:eager_default_key, default: "default_value")
    assert_equal "default_value", result

    record = DBConfig::ConfigRecord.find_by(key: "eager_default_key")
    assert_equal false, record.eager_load  # Should be default false
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

  test "can set and get nil values" do
    DBConfig.set(:nil_key, nil)
    assert_nil DBConfig.get(:nil_key)

    # Verify it's stored with correct type
    record = DBConfig::ConfigRecord.find_by(key: "nil_key")
    assert_equal "NilClass", record.value_type
    assert_nil record.value  # nil stored as NULL in database
  end

  test "can use nil as default value" do
    # Key doesn't exist yet
    assert_raises(DBConfig::NotFoundError) do
      DBConfig.get(:nil_default_test)
    end

    # Get with nil default should create and return nil
    result = DBConfig.get(:nil_default_test, default: nil)
    assert_nil result

    # Key should now exist with nil value
    assert_nil DBConfig.get(:nil_default_test)

    # Verify it was saved to database with correct type
    record = DBConfig::ConfigRecord.find_by(key: "nil_default_test")
    assert_not_nil record
    assert_nil record.value
    assert_equal "NilClass", record.value_type
  end

  test "returns existing nil value when key exists and default is provided" do
    # Set nil value first
    DBConfig.set(:existing_nil_key, nil)

    # Get with non-nil default should return existing nil value, not default
    result = DBConfig.get(:existing_nil_key, default: "default_value")
    assert_nil result

    # Verify the value wasn't changed
    assert_nil DBConfig.get(:existing_nil_key)
  end

  test "returns existing non-nil value when key exists and nil default is provided" do
    # Set non-nil value first
    DBConfig.set(:existing_value_key, "existing_value")

    # Get with nil default should return existing value, not nil
    result = DBConfig.get(:existing_value_key, default: nil)
    assert_equal "existing_value", result

    # Verify the value wasn't changed
    assert_equal "existing_value", DBConfig.get(:existing_value_key)
  end

  test "stores correct value_type for nil" do
    DBConfig.set(:nil_type_test, nil)
    assert_equal "NilClass", DBConfig::ConfigRecord.find_by(key: "nil_type_test").value_type
  end

  test "nil default works with eager_load" do
    # Create key with nil default
    result = DBConfig.get(:nil_eager_test, default: nil)
    assert_nil result

    # Set eager_load flag
    DBConfig.eager_load(:nil_eager_test, true)

    record = DBConfig::ConfigRecord.find_by(key: "nil_eager_test")
    assert_equal true, record.eager_load
    assert_equal "NilClass", record.value_type
    assert_nil DBConfig.get(:nil_eager_test)
  end

  test "can delete existing configuration" do
    # Set up a configuration
    DBConfig.set(:delete_test, "value to delete")
    assert_equal "value to delete", DBConfig.get(:delete_test)

    # Verify it exists in database
    assert_not_nil DBConfig::ConfigRecord.find_by(key: "delete_test")

    # Delete it
    result = DBConfig.delete(:delete_test)
    assert_equal true, result

    # Verify it no longer exists
    assert_nil DBConfig::ConfigRecord.find_by(key: "delete_test")

    # Verify get raises error
    assert_raises(DBConfig::NotFoundError) do
      DBConfig.get(:delete_test)
    end
  end

  test "delete returns false for non-existent key" do
    # Try to delete a key that doesn't exist
    result = DBConfig.delete(:non_existent_key)
    assert_equal false, result

    # Should still return false on subsequent calls
    result2 = DBConfig.delete(:non_existent_key)
    assert_equal false, result2
  end

  test "delete works with different key types" do
    # Test with string key
    DBConfig.set("string_key_delete", "string value")
    assert_equal true, DBConfig.delete("string_key_delete")

    # Test with symbol key
    DBConfig.set(:symbol_key_delete, "symbol value")
    assert_equal true, DBConfig.delete(:symbol_key_delete)

    # Test with integer key
    DBConfig.set(123, "integer key value")
    assert_equal true, DBConfig.delete(123)
  end

  test "delete works with different value types" do
    # Delete string value
    DBConfig.set(:string_delete, "hello")
    assert_equal true, DBConfig.delete(:string_delete)

    # Delete integer value
    DBConfig.set(:int_delete, 42)
    assert_equal true, DBConfig.delete(:int_delete)

    # Delete array value
    DBConfig.set(:array_delete, [1, 2, 3])
    assert_equal true, DBConfig.delete(:array_delete)

    # Delete hash value
    DBConfig.set(:hash_delete, {"key" => "value"})
    assert_equal true, DBConfig.delete(:hash_delete)

    # Delete nil value
    DBConfig.set(:nil_delete, nil)
    assert_equal true, DBConfig.delete(:nil_delete)

    # Delete boolean value
    DBConfig.set(:bool_delete, true)
    assert_equal true, DBConfig.delete(:bool_delete)
  end

  test "delete removes record completely from database" do
    # Create multiple configurations
    DBConfig.set(:config1, "value1")
    DBConfig.set(:config2, "value2")
    DBConfig.set(:config3, "value3")

    initial_count = DBConfig::ConfigRecord.count
    assert_equal 3, initial_count

    # Delete one
    DBConfig.delete(:config2)

    # Count should decrease
    assert_equal 2, DBConfig::ConfigRecord.count

    # Remaining configs should still exist
    assert_equal "value1", DBConfig.get(:config1)
    assert_equal "value3", DBConfig.get(:config3)

    # Deleted config should not exist
    assert_raises(DBConfig::NotFoundError) do
      DBConfig.get(:config2)
    end
  end
end
