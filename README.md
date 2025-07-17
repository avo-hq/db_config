# DBConfig

Database-backed configuration store for Rails with automatic type conversion, default values, and high-performance eager loading.

## Features

- **Type-safe storage**: Auto-detects and converts strings, integers, floats, booleans, arrays, hashes, and nil
- **Default values**: Creates missing configs automatically when accessed with defaults
- **⚡ Eager loading**: Cache frequently accessed configs for near-zero database overhead
- **Simple API**: `get`, `set`, `delete`, `eager_load` methods

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
DBConfig.set(:site_title, "My App")
DBConfig.set(:max_users, 1000)
DBConfig.set(:enabled, true)
DBConfig.set(:rate, 0.05)
DBConfig.set(:tags, ["ruby", "rails"])
DBConfig.set(:config, {api: "https://api.example.com", timeout: 30})
DBConfig.set(:feature, nil)

# Get with type preservation
DBConfig.get(:max_users)    # => 1000 (Integer)
DBConfig.get(:enabled)      # => true (Boolean)

# Get with defaults (creates if missing)
DBConfig.get(:page_size, default: 25)     # => 25 (creates if missing)
DBConfig.get(:missing_key)                # => raises DBConfig::NotFoundError

# Delete configurations  
DBConfig.delete(:old_setting)  # => true/false
```

### ⚡ Eager Loading

```ruby
# Mark configs for eager loading (loaded once per request, cached)
DBConfig.set(:api_key, "secret123")
DBConfig.eager_load(:api_key, true)  # Now super fast!
```

> [!TIP]
> **Good for**: API keys, site settings, frequently accessed configs  
> **Avoid**: Rarely used configs, large data, user-specific settings

## Supported Types

Auto-detects and preserves: String, Integer, Float, Boolean, Array, Hash, nil

> [!TIP]
> Use defaults to avoid exceptions: `DBConfig.get(:missing, default: "fallback")`

## API

**`DBConfig.set(key, value)`** - Store any value  
**`DBConfig.get(key, default:)`** - Retrieve value (with optional default)  
**`DBConfig.delete(key)`** - Remove configuration  
**`DBConfig.eager_load(key, enabled)`** - Toggle eager loading

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avo-hq/db_config.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
