# DBConfig

Database-backed configuration store for Rails with automatic type conversion, default values, and high-performance eager loading.

## Features

- **Type-safe storage**: Auto-detects and converts strings, integers, floats, booleans, arrays, hashes, and nil

- **⚡ Eager loading**: Cache frequently accessed configs for near-zero database overhead
- **Simple API**: `get`/`read`, `get!`, `set`/`write`, `delete`, `exist?`, `eager_load` methods

## Installation & Setup

```ruby
# Gemfile
gem "db_config"
```

```bash
bundle install
rails generate db_config:install
rails db:migrate
```

## Usage

```ruby
# Set any data type - auto-detected and preserved
DBConfig.set(:max_users, 1000)
DBConfig.write(:site_title, "My App") # alias for set
DBConfig.set(:enabled, true)
DBConfig.set(:rate, 0.05)
DBConfig.set(:tags, ["ruby", "rails"])
DBConfig.set(:config, {api: "https://api.example.com", timeout: 30})
DBConfig.set(:feature, nil)

# Get with type preservation
DBConfig.get(:max_users)    # => 1000 (Integer)
DBConfig.read(:enabled)     # => true (Boolean) - alias for get



# Get missing config (safe - returns nil)
DBConfig.get(:missing_key)                # => nil

# Check if a config exists
DBConfig.exist?(:page_size)               # => true or false

# Use || operator for fallback values
DBConfig.get(:page_size) || 25            # => 25 if :page_size not set

# Get missing config with get! (raises error)
DBConfig.get!(:missing_key)               # => raises DBConfig::NotFoundError
```

### Exception Handling

```ruby
# Safe get - never raises exceptions, returns nil if not found
value = DBConfig.get(:api_token)          # => nil if not found

# Use || operator for fallback values
api_token = DBConfig.get(:api_token) || "default_token"

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
# Delete configurations
DBConfig.delete(:old_setting)             # => true if deleted, false if not found
```

### ⚡ Eager Loading

> [!NOTE]
> Eager loaded configs are cached per request and automatically synced when changed

```ruby
# Mark configs for eager loading (loaded once per request, cached)
DBConfig.set(:api_key, "secret123")
DBConfig.eager_load(:api_key, true)       # Enable eager loading
DBConfig.eager_load(:api_key, false)      # Disable eager loading

# Now served from cache (no database query)
DBConfig.get(:api_key)                    # Served from cache
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
DBConfig.read(:api_key)                   # Same as DBConfig.get(:api_key)
api_key = DBConfig.read(:api_key) || "default"
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

### `DBConfig.delete(key)`
Removes configuration from database.

**Parameters:**
- `key` (Symbol/String) - Configuration key to remove

**Returns:** `true` if deleted, `false` if key didn't exist

### `DBConfig.eager_load(key, enabled)`
Toggles eager loading for frequently accessed configurations.

**Parameters:**
- `key` (Symbol/String) - Configuration key
- `enabled` (Boolean) - Enable (true) or disable (false) eager loading

**Returns:** The enabled state

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avo-hq/db_config.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
