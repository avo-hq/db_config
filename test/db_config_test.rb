require "test_helper"

class DBConfigTest < ActiveSupport::TestCase
  def setup
    # Clean up any existing test data
    DBConfig::ConfigRecord.delete_all if defined?(DBConfig::ConfigRecord)
  end

  test "it has a version number" do
    assert DBConfig::VERSION
  end

  test "returns nil when getting non-existent key without default" do
    assert_nil DBConfig.get(:non_existent_key)
  end

  test "get! raises NotFoundError when getting non-existent key" do
    assert_raises(DBConfig::NotFoundError) do
      DBConfig.get!(:non_existent_key)
    end
  end

  test "get! returns value when key exists" do
    DBConfig.set(:existing_key, "test_value")
    assert_equal "test_value", DBConfig.get!(:existing_key)
  end

  test "get! doesn't accept default parameter" do
    # get! should not have a default parameter
    assert_raises(ArgumentError) do
      DBConfig.get!(:some_key, "some_default")
    end
  end

  test "get! works with all data types" do
    DBConfig.set(:string_key, "hello")
    DBConfig.set(:int_key, 42)
    DBConfig.set(:bool_key, true)
    DBConfig.set(:array_key, [1, 2, 3])
    DBConfig.set(:hash_key, {"key" => "value"})
    DBConfig.set(:nil_key, nil)

    assert_equal "hello", DBConfig.get!(:string_key)
    assert_equal 42, DBConfig.get!(:int_key)
    assert_equal true, DBConfig.get!(:bool_key)
    assert_equal [1, 2, 3], DBConfig.get!(:array_key)
    assert_equal({"key" => "value"}, DBConfig.get!(:hash_key))
    assert_nil DBConfig.get!(:nil_key)
  end



  test "returns existing value when key exists" do
    # Set a value first
    DBConfig.set(:existing_key, "existing_value")

    # Get should return existing value
    result = DBConfig.get(:existing_key)
    assert_equal "existing_value", result

    # Verify the value wasn't changed
    assert_equal "existing_value", DBConfig.get(:existing_key)
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

  test "can set and get nil values" do
    DBConfig.set(:nil_key, nil)
    assert_nil DBConfig.get(:nil_key)

    # Verify it's stored with correct type
    record = DBConfig::ConfigRecord.find_by(key: "nil_key")
    assert_equal "NilClass", record.value_type
    assert_nil record.value  # nil stored as NULL in database
  end



  test "returns existing nil value when key exists" do
    # Set nil value first
    DBConfig.set(:existing_nil_key, nil)

    # Get should return existing nil value
    result = DBConfig.get(:existing_nil_key)
    assert_nil result

    # Verify the value wasn't changed
    assert_nil DBConfig.get(:existing_nil_key)
  end

  test "returns existing non-nil value when key exists" do
    # Set non-nil value first
    DBConfig.set(:existing_value_key, "existing_value")

    # Get should return existing value
    result = DBConfig.get(:existing_value_key)
    assert_equal "existing_value", result

    # Verify the value wasn't changed
    assert_equal "existing_value", DBConfig.get(:existing_value_key)
  end

  test "stores correct value_type for nil" do
    DBConfig.set(:nil_type_test, nil)
    assert_equal "NilClass", DBConfig::ConfigRecord.find_by(key: "nil_type_test").value_type
  end

  test "get on non-existent key doesn't create record for eager_load testing" do
    # Get on non-existent key returns nil and doesn't create record
    result = DBConfig.get(:nil_eager_test)
    assert_nil result

    # Can't set eager_load flag on non-existent record
    assert_raises(DBConfig::NotFoundError) do
      DBConfig.eager_load(:nil_eager_test, true)
    end

    # Still no record should exist
    record = DBConfig::ConfigRecord.find_by(key: "nil_eager_test")
    assert_nil record
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

    # Verify get returns nil
    assert_nil DBConfig.get(:delete_test)
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

    # Deleted config should return nil
    assert_nil DBConfig.get(:config2)
  end

  # Eager Loading Tests
  test "eager loading loads all marked configs" do
    # Create some configs with eager_load enabled
    DBConfig.set(:eager_config1, "value1")
    DBConfig.set(:eager_config2, 42)
    DBConfig.set(:normal_config, "normal")

    # Mark some as eager load
    DBConfig.eager_load(:eager_config1, true)
    DBConfig.eager_load(:eager_config2, true)

    # Clear current attributes to simulate new request
    DBConfig::Current.reset

    # Load eager configs
    DBConfig::Current.load_eager_configs!

    # Check that eager configs are loaded
    cached_records = DBConfig::Current.cached_records

    assert_equal 2, cached_records.size
    assert cached_records.key?("eager_config1")
    assert cached_records.key?("eager_config2")
    assert_not cached_records.key?("normal_config")

    # Check values are correct
    assert_equal "value1", DBConfig.get(:eager_config1)
    assert_equal 42, DBConfig.get(:eager_config2)
  end

  test "get method checks eager loaded configs first" do
    # Create and set config as eager load
    DBConfig.set(:test_config, "original_value")
    DBConfig.eager_load(:test_config, true)

    # Load eager configs
    DBConfig::Current.load_eager_configs!

    # Verify it's in the cache
    assert DBConfig::Current.cached_records.key?("test_config")

    # Get should return from cache
    assert_equal "original_value", DBConfig.get(:test_config)
  end

  test "get method falls back to database query for non-eager configs" do
    # Create a non-eager config
    DBConfig.set(:non_eager_config, "database_value")

    # Clear cache
    DBConfig::Current.reset

    # Get should query database directly (not cache the result)
    assert_equal "database_value", DBConfig.get(:non_eager_config)

    # Should NOT be cached (since it's not eager loaded)
    assert_not DBConfig::Current.cached_records.key?("non_eager_config")
  end

  test "set method updates eager loaded cache" do
    # Create and set config as eager load
    DBConfig.set(:cache_test, "original")
    DBConfig.eager_load(:cache_test, true)

    # Load eager configs
    DBConfig::Current.load_eager_configs!

    # Update the value
    DBConfig.set(:cache_test, "updated")

    # Cache should be updated
    assert_equal "updated", DBConfig.get(:cache_test)
  end

  test "delete method removes from cache" do
    # Create and set config as eager load
    DBConfig.set(:delete_test, "value")
    DBConfig.eager_load(:delete_test, true)

    # Load eager configs
    DBConfig::Current.load_eager_configs!

    # Verify it's cached
    assert DBConfig::Current.cached_records.key?("delete_test")

    # Delete the config
    assert DBConfig.delete(:delete_test)

    # Should be removed from cache
    assert_not DBConfig::Current.cached_records.key?("delete_test")
  end

  test "eager_load method updates cache appropriately" do
    # Create a config
    DBConfig.set(:toggle_test, "value")

    # Initially not eager loaded
    DBConfig::Current.load_eager_configs!
    assert_not DBConfig::Current.cached_records.key?("toggle_test")

    # Enable eager loading
    DBConfig.eager_load(:toggle_test, true)

    # Should now be in cache
    assert DBConfig::Current.cached_records.key?("toggle_test")
    assert_equal "value", DBConfig.get(:toggle_test)

    # Disable eager loading
    DBConfig.eager_load(:toggle_test, false)

    # Should still be in cache (since we accessed it)
    assert DBConfig::Current.cached_records.key?("toggle_test")
  end

  test "current attributes are thread safe" do
    # This test simulates multiple threads/requests
    DBConfig.set(:thread_test, "value1")
    DBConfig.eager_load(:thread_test, true)

    # Simulate first request
    DBConfig::Current.load_eager_configs!
    first_value = DBConfig.get(:thread_test)
    assert_equal "value1", first_value

    # Simulate clearing for new request (Current attributes reset)
    DBConfig::Current.reset

    # Modify config in database
    DBConfig.set(:thread_test, "value2")

    # Simulate second request
    DBConfig::Current.load_eager_configs!
    second_value = DBConfig.get(:thread_test)

    # Second request should have updated value
    assert_equal "value2", second_value
  end

  test "supports all value types in eager loading" do
    DBConfig.set(:string_config, "string_value")
    DBConfig.set(:integer_config, 123)
    DBConfig.set(:float_config, 45.67)
    DBConfig.set(:boolean_config, true)
    DBConfig.set(:array_config, [1, 2, 3])
    DBConfig.set(:hash_config, {key: "value"})
    DBConfig.set(:nil_config, nil)

    # Mark all as eager load
    %w[string_config integer_config float_config boolean_config array_config hash_config nil_config].each do |key|
      DBConfig.eager_load(key, true)
    end

    # Load and verify
    DBConfig::Current.load_eager_configs!

    assert_equal "string_value", DBConfig.get(:string_config)
    assert_equal 123, DBConfig.get(:integer_config)
    assert_equal 45.67, DBConfig.get(:float_config)
    assert_equal true, DBConfig.get(:boolean_config)
    assert_equal [1, 2, 3], DBConfig.get(:array_config)
    assert_equal({"key" => "value"}, DBConfig.get(:hash_config))
    assert_nil DBConfig.get(:nil_config)
  end

  test "model callbacks automatically sync cache on database changes" do
    # Create a config
    DBConfig.set(:sync_test, "original")

    # Get it to cache it
    assert_equal "original", DBConfig.get(:sync_test)
    assert DBConfig::Current.cached_records.key?("sync_test")

    # Modify the record directly in database (simulating external change)
    record = DBConfig::ConfigRecord.find_by(key: "sync_test")
    record.update!(value: "modified_externally")

    # Cache should automatically have new value due to callbacks
    cached_record = DBConfig::Current.cached_records["sync_test"]
    assert_equal "modified_externally", cached_record.value

    # Get should return the updated value
    assert_equal "modified_externally", DBConfig.get(:sync_test)
  end

  test "model callbacks automatically remove deleted records from cache" do
    # Create and cache a config
    DBConfig.set(:delete_sync_test, "value")
    DBConfig.get(:delete_sync_test) # Cache it
    assert DBConfig::Current.cached_records.key?("delete_sync_test")

    # Delete record directly from database
    DBConfig::ConfigRecord.find_by(key: "delete_sync_test").destroy!

    # Cache should automatically have record removed due to callbacks
    assert_not DBConfig::Current.cached_records.key?("delete_sync_test")
  end

  test "model callbacks handle cache sync automatically" do
    # Create and mark as eager load (will be cached via callback)
    DBConfig.set(:callback_test, "value")
    DBConfig.eager_load(:callback_test, true)

    # Load eager configs to get it in cache
    DBConfig::Current.load_eager_configs!
    assert DBConfig::Current.cached_records.key?("callback_test")
    original_record = DBConfig::Current.cached_records["callback_test"]

    # Update the record directly - callback should sync cache
    original_record.update!(value: "updated_via_callback")

    # Cache should be automatically updated via callback
    cached_record = DBConfig::Current.cached_records["callback_test"]
    assert_equal "updated_via_callback", cached_record.value

    # Delete the record - callback should remove from cache
    original_record.destroy!
    assert_not DBConfig::Current.cached_records.key?("callback_test")
  end

  test "all operations automatically sync cache" do
    # Set operation syncs
    DBConfig.set(:auto_sync_test, "value1")
    cached_record = DBConfig::Current.cached_records["auto_sync_test"]
    assert_equal "value1", cached_record.value

    # Update via set syncs
    DBConfig.set(:auto_sync_test, "value2")
    cached_record = DBConfig::Current.cached_records["auto_sync_test"]
    assert_equal "value2", cached_record.value

    # Eager load operation syncs
    DBConfig.eager_load(:auto_sync_test, true)
    cached_record = DBConfig::Current.cached_records["auto_sync_test"]
    assert_equal true, cached_record.eager_load

    # Delete operation syncs (removes from cache)
    DBConfig.delete(:auto_sync_test)
    assert_not DBConfig::Current.cached_records.key?("auto_sync_test")
  end

  test "read alias works like get" do
    DBConfig.set(:alias_test, "test_value")

    # read should work exactly like get
    assert_equal "test_value", DBConfig.read(:alias_test)
    assert_equal DBConfig.get(:alias_test), DBConfig.read(:alias_test)

    # read should return nil for non-existent keys
    assert_nil DBConfig.read(:non_existent)
  end

  test "write alias works like set" do
    # write should work exactly like set
    result = DBConfig.write(:write_test, "written_value")
    assert_equal "written_value", result
    assert_equal "written_value", DBConfig.get(:write_test)

    # write should handle different data types
    DBConfig.write(:write_int, 42)
    DBConfig.write(:write_bool, true)
    DBConfig.write(:write_array, [1, 2, 3])

    assert_equal 42, DBConfig.read(:write_int)
    assert_equal true, DBConfig.read(:write_bool)
    assert_equal [1, 2, 3], DBConfig.read(:write_array)
  end

  test "aliases and original methods are interchangeable" do
    # Mix and match read/get and write/set
    DBConfig.write(:mix_test, "original")
    assert_equal "original", DBConfig.read(:mix_test)
    assert_equal "original", DBConfig.get(:mix_test)

    DBConfig.set(:mix_test, "updated")
    assert_equal "updated", DBConfig.read(:mix_test)
    assert_equal "updated", DBConfig.get(:mix_test)
  end

  test "exist? returns true for existing keys" do
    DBConfig.set(:exist_test, "value")
    assert DBConfig.exist?(:exist_test)

    # Works with different data types
    DBConfig.set(:exist_int, 42)
    DBConfig.set(:exist_bool, true)
    DBConfig.set(:exist_nil, nil)
    DBConfig.set(:exist_array, [1, 2, 3])

    assert DBConfig.exist?(:exist_int)
    assert DBConfig.exist?(:exist_bool)
    assert DBConfig.exist?(:exist_nil)  # nil values still exist
    assert DBConfig.exist?(:exist_array)
  end

  test "exist? returns false for non-existent keys" do
    assert_not DBConfig.exist?(:non_existent_key)
    assert_not DBConfig.exist?("string_key_that_doesnt_exist")

    # Returns false even after setting and deleting
    DBConfig.set(:temp_key, "temp")
    assert DBConfig.exist?(:temp_key)

    DBConfig.delete(:temp_key)
    assert_not DBConfig.exist?(:temp_key)
  end

  test "exist? works with both symbol and string keys" do
    DBConfig.set(:symbol_exist_test, "value")

    # Both forms should work
    assert DBConfig.exist?(:symbol_exist_test)
    assert DBConfig.exist?("symbol_exist_test")
  end

  test "exist? works with eager loaded keys" do
    DBConfig.set(:eager_exist_test, "value")
    DBConfig.eager_load(:eager_exist_test, true)

    # Should still return true for eager loaded keys
    assert DBConfig.exist?(:eager_exist_test)

    # Disable eager loading and it should still exist
    DBConfig.eager_load(:eager_exist_test, false)
    assert DBConfig.exist?(:eager_exist_test)
  end

  test "fetch returns existing value when key exists" do
    DBConfig.set(:fetch_existing, "existing_value")

    # Should return existing value without executing block
    result = DBConfig.fetch(:fetch_existing) { "block_value" }
    assert_equal "existing_value", result

    # Value should remain unchanged
    assert_equal "existing_value", DBConfig.get(:fetch_existing)
  end

  test "fetch executes block and stores result when key doesn't exist" do
    # Key doesn't exist initially
    assert_not DBConfig.exist?(:fetch_new)

    # Should execute block and store the result
    result = DBConfig.fetch(:fetch_new) { 42 }
    assert_equal 42, result

    # Should now exist in database
    assert DBConfig.exist?(:fetch_new)
    assert_equal 42, DBConfig.get(:fetch_new)
  end

  test "fetch returns nil when key doesn't exist and no block given" do
    result = DBConfig.fetch(:non_existent_fetch)
    assert_nil result
  end

  test "fetch works with different data types in block" do
    # String
    result1 = DBConfig.fetch(:fetch_string) { "default_string" }
    assert_equal "default_string", result1
    assert_equal "default_string", DBConfig.get(:fetch_string)

    # Integer
    result2 = DBConfig.fetch(:fetch_integer) { 123 }
    assert_equal 123, result2
    assert_equal 123, DBConfig.get(:fetch_integer)

    # Boolean
    result3 = DBConfig.fetch(:fetch_boolean) { true }
    assert_equal true, result3
    assert_equal true, DBConfig.get(:fetch_boolean)

    # Array
    result4 = DBConfig.fetch(:fetch_array) { [1, 2, 3] }
    assert_equal [1, 2, 3], result4
    assert_equal [1, 2, 3], DBConfig.get(:fetch_array)

    # Hash
    result5 = DBConfig.fetch(:fetch_hash) { {key: "value"} }
    assert_equal({"key" => "value"}, result5)  # Symbol keys become string keys
    assert_equal({"key" => "value"}, DBConfig.get(:fetch_hash))

    # Nil
    result6 = DBConfig.fetch(:fetch_nil) { nil }
    assert_nil result6
    assert_nil DBConfig.get(:fetch_nil)
  end

  test "fetch block is only executed once" do
    counter = 0

    # First call should execute block
    result1 = DBConfig.fetch(:fetch_counter) do
      counter += 1
      "value_#{counter}"
    end
    assert_equal "value_1", result1
    assert_equal 1, counter

    # Second call should return stored value without executing block
    result2 = DBConfig.fetch(:fetch_counter) do
      counter += 1
      "value_#{counter}"
    end
    assert_equal "value_1", result2
    assert_equal 1, counter  # Counter should not have incremented
  end

  test "fetch works with symbol and string keys" do
    # Use symbol key
    result1 = DBConfig.fetch(:fetch_symbol_test) { "symbol_value" }
    assert_equal "symbol_value", result1

    # Should work with string key too (same underlying key)
    result2 = DBConfig.fetch("fetch_symbol_test") { "string_value" }
    assert_equal "symbol_value", result2  # Should return existing value
  end

  test "fetch works with complex block logic" do
    # Block can contain complex logic
    result = DBConfig.fetch(:fetch_complex) do
      base = 10
      multiplier = 5
      base * multiplier + 7
    end
    assert_equal 57, result
    assert_equal 57, DBConfig.get(:fetch_complex)
  end
end
