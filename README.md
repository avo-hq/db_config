# DBConfig

Database-backed configuration store for Rails with automatic type conversion, default values, and high-performance eager loading.

## Features

- **Type-safe storage**: Auto-detects and converts strings, integers, floats, booleans, arrays, hashes, and nil

- **Eager loading**: Cache frequently accessed configs for near-zero database overhead
- **Simple API**: `get`/`read`, `get!`, `set`/`write`, `update`, `delete`, `exist?`, `fetch` methods

## Installation & Setup

```ruby
# Gemfile
gem "db_config"
```

```bash
bundle install
```
```bash
rails generate db_config:install
```
```bash
rails db:migrate
```

## Usage

### Set any data type - auto-detected and preserved
```ruby
DBConfig.set(:max_users, 1000)
DBConfig.write(:site_title, "My App") # write is an alias for set
DBConfig.set(:enabled, true)
DBConfig.set(:rate, 0.05)
DBConfig.set(:tags, ["ruby", "rails"])
DBConfig.set(:config, {api: "https://api.example.com", timeout: 30})
DBConfig.set(:feature, nil)
```

### Get with type preservation
```ruby
DBConfig.get(:max_users)    # => 1000 (Integer)
DBConfig.read(:enabled)     # => true (Boolean) - alias for get

# Get missing config (safe - returns nil)
DBConfig.get(:missing_key)                # => nil

# Get missing config with get! (raises error)
DBConfig.get!(:missing_key)               # => raises DBConfig::NotFoundError

# Check if a config exists
DBConfig.exist?(:page_size)               # => true or false

# Fetch with block - stores block result if key doesn't exist
DBConfig.fetch(:page_size) { 25 }         # => 25 (stores if not found)

# Use || operator for fallback values
DBConfig.get(:page_size) || 25            # => 25 if :page_size not set

```

### Exception Handling

```ruby
# Strict get - raises exception if not found
begin
  value = DBConfig.get!(:api_token)
rescue DBConfig::NotFoundError => e
  Rails.logger.warn "Missing config: #{e.message}"
  value = "default_token"
end
```

### Managing Configurations

```ruby
# Update configurations with type safety
DBConfig.set(:max_users, 1000)                              # Set value and type to Integer
DBConfig.update(:max_users, value: 500)                     # Update value keeping same type

DBConfig.set(:site_enabled, "true")                         # Set value and type to String
DBConfig.update(:site_enabled, type: "Boolean")             # Convert "true" string to boolean true

DBConfig.set(:cache_ttl, 3600)                              # Set value and type to Integer
DBConfig.update(:cache_ttl, value: 4600, eager_load: true)  # Update value and enable eager loading

DBConfig.delete(:old_setting)                               # => true if deleted, false if not found
```

### ⚡ Eager Loading

> [!NOTE]
> Eager loaded configs are cached per request and automatically synced when changed

```ruby
# Mark configs for eager loading (loaded once per request, cached)
DBConfig.set(:api_key, "secret123")
DBConfig.update(:api_key, eager_load: true)   # Enable eager loading

# Now served from cache (no database query)
DBConfig.get(:api_key)                         # Served from cache

DBConfig.update(:api_key, eager_load: false)  # Disable eager loading
```

> [!TIP]
> **Good for**: API keys, site settings, frequently accessed configs
> **Avoid**: Rarely used configs, large data, user-specific settings

## Supported Types

Auto-detects and preserves: String, Integer, Float, Boolean, Array, Hash, nil

```ruby
# All types preserved exactly
DBConfig.set(:string, "hello")           # => "hello" (String)
DBConfig.set(:integer, 42)               # => 42 (Integer)
DBConfig.set(:float, 3.14)               # => 3.14 (Float)
DBConfig.set(:boolean, true)             # => true (Boolean)
DBConfig.set(:array, [1, 2, 3])          # => [1, 2, 3] (Array)
DBConfig.set(:hash, {a: 1})              # => {a: 1} (Hash)
DBConfig.set(:null, nil)                 # => nil (NilClass)
```

## API Reference

### `DBConfig.get(key)`
Safely retrieves configuration value for the given key.

**Parameters:**
- `key` (Symbol/String) - Configuration key to retrieve

**Returns:** Stored value with original type preserved, or `nil` if not found

**Raises:** Never raises exceptions

**Fallback Pattern:**
Use the `||` operator to provide fallback values when keys don't exist:

```ruby
# Recommended pattern for fallback values
page_size = DBConfig.get(:page_size) || 25
```


### `DBConfig.get!(key)`
Strictly retrieves configuration value for the given key.

**Parameters:**
- `key` (Symbol/String) - Configuration key to retrieve

**Returns:** Stored value with original type preserved

**Raises:** `DBConfig::NotFoundError` if key doesn't exist

### `DBConfig.read(key)` (alias for `get`)
Convenience alias for `DBConfig.get(key)`. Works exactly the same way.

```ruby
DBConfig.read(:api_key) # Same as DBConfig.get(:api_key)
```

### `DBConfig.set(key, value)`
Stores configuration value with automatic type detection.

**Parameters:**
- `key` (Symbol/String) - Configuration key
- `value` (Any) - Value to store (String, Integer, Float, Boolean, Array, Hash, nil)

**Returns:** The stored value

### `DBConfig.write(key, value)` (alias for `set`)
Convenience alias for `DBConfig.set(key, value)`. Works exactly the same way.

```ruby
DBConfig.write(:api_key, "secret123")     # Same as DBConfig.set(:api_key, "secret123")
```

### `DBConfig.exist?(key)`
Checks if a configuration key exists in the database.

**Parameters:**
- `key` (Symbol/String) - Configuration key to check

**Returns:** `true` if the key exists, `false` otherwise

**Raises:** Never raises exceptions

```ruby
DBConfig.exist?(:api_key)                 # => true or false
DBConfig.exist?("api_key")                # Works with strings too
```

### `DBConfig.fetch(key, &block)`
Gets the value if it exists, or executes the block and stores the result if it doesn't.

**Parameters:**
- `key` (Symbol/String) - Configuration key to fetch
- `&block` - Block to execute if key doesn't exist (optional)

**Returns:** Existing value if found, block result (which gets stored), or `nil` if key doesn't exist and no block given

```ruby
# If key exists, returns existing value (block not executed)
DBConfig.set(:api_timeout, 30)
timeout = DBConfig.fetch(:api_timeout) { 60 }    # => 30 (existing value)

# If key doesn't exist, executes block and stores result
cache_size = DBConfig.fetch(:cache_size) { 100 } # => 100 (stores 100)
cache_size = DBConfig.fetch(:cache_size) { 200 } # => 100 (returns stored value)

# Works with any data type
features = DBConfig.fetch(:features) { ["feature1", "feature2"] }
config = DBConfig.fetch(:api_config) { {endpoint: "api.com", timeout: 30} }

# Returns nil if no block given and key doesn't exist
DBConfig.fetch(:missing_key)  # => nil
```

### `DBConfig.delete(key)`
Removes configuration from database.

**Parameters:**
- `key` (Symbol/String) - Configuration key to remove

**Returns:** `true` if deleted, `false` if key didn't exist

### `DBConfig.update(key, **options)`
Updates configuration entry with intelligent type conversion and validation.

**Parameters:**
- `key` (Symbol/String) - Configuration key (must exist)
- `**options` - Keyword arguments for updates:
  - `value: Any` - New value to store (with type compatibility checking)
  - `type: String` - Target type for conversion ("String", "Integer", "Float", "Boolean", "Array", "Hash", "NilClass")
  - `eager_load: Boolean` - Enable/disable eager loading

**Returns:** The updated value in its final type

**Type Compatibility:**
- When updating `value`: New values can change type automatically (e.g., "hello" → 42 changes String to Integer)
- When updating `type`: Only compatible conversions are allowed (e.g., "123" → Integer, "hello" → Integer fails)
- Incompatible type conversions raise `ArgumentError` with detailed message

**Examples:**
```ruby
# Update value (can change type automatically)
DBConfig.set(:config_value, "hello")
DBConfig.update(:config_value, value: 42)    # String → Integer (automatic)

# Change type explicitly (requires compatibility)
DBConfig.set(:enabled, "true")              # "true" is set as a string
DBConfig.update(:enabled, type: "Boolean")  # "true" → true (compatible conversion)

# Update multiple attributes
DBConfig.update(:cache_size, value: 1000, eager_load: true)

# Examples from the specification
DBConfig.update(:key, eager_load: true)
DBConfig.update(:key, type: "Boolean")      # Only works if current value is compatible
DBConfig.update(:key, eager_load: true, value: true)  # ✅ Always works

# Fails only on incompatible TYPE conversions (not value updates)
DBConfig.set(:username, "admin")
DBConfig.update(:username, type: "Integer")  # ❌ Fails: "admin" can't become Integer
DBConfig.update(:username, value: 123)       # ✅ Works: new value can be any type
```

**Raises:**
- `DBConfig::NotFoundError` if key doesn't exist
- `ArgumentError` for invalid types or incompatible conversions

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avo-hq/db_config.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
