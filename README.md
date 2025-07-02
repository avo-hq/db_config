# DBConfig

A Rails gem that provides a database-backed configuration store for your applications. Store and retrieve configuration values dynamically with support for different data types and eager loading.

## Features

- **Database-backed configuration**: Store configuration values in your database
- **Type-safe storage**: Automatic type detection and conversion for strings, integers, floats, booleans, arrays, and hashes
- **Eager loading support**: Mark configurations for eager loading to improve performance
- **Simple API**: Clean and intuitive interface with `get`, `set`, and `eager_load` methods
- **Error handling**: Proper exception handling for missing configurations
- **Rails integration**: Seamless integration with Rails applications

## Installation

Add this line to your application's Gemfile:

```ruby
gem "db_config"
```

And then execute:
```bash
$ bundle install
```

Or install it yourself as:
```bash
$ gem install db_config
```

## Setup

After installing the gem, run the install generator to create the necessary database table:

```bash
$ rails generate db_config:install
$ rails db:migrate
```

This will create a `db_config` table with the following schema:

```ruby
create_table :db_config do |t|
  t.string :key, null: false        # The configuration key (indexed)
  t.string :value, null: false      # The stored value (as string)
  t.string :value_type, null: false # The original data type
  t.boolean :eager_load, default: false # Whether to eager load this config
  t.timestamps null: false
end
```

## Usage

### Setting Configuration Values

```ruby
# Set string values
DBConfig.set(:site_title, "My Awesome Site")

# Set integer values
DBConfig.set(:max_users, 1000)

# Set boolean values
DBConfig.set(:maintenance_mode, false)

# Set float values
DBConfig.set(:conversion_rate, 0.05)

# Set array values
DBConfig.set(:allowed_countries, ["US", "CA", "UK"])

# Set hash values
DBConfig.set(:api_settings, {
  endpoint: "https://api.example.com",
  timeout: 30,
  retries: 3
})

# Set complex nested structures
DBConfig.set(:user_preferences, {
  theme: "dark",
  notifications: {
    email: true,
    push: false,
    categories: ["updates", "security"]
  }
})
```

### Getting Configuration Values

```ruby
# Get values (returns original data type)
site_title = DBConfig.get(:site_title)        # => "My Awesome Site"
max_users = DBConfig.get(:max_users)          # => 1000
maintenance = DBConfig.get(:maintenance_mode) # => false
rate = DBConfig.get(:conversion_rate)         # => 0.05
countries = DBConfig.get(:allowed_countries)  # => ["US", "CA", "UK"]
settings = DBConfig.get(:api_settings)        # => { "endpoint" => "https://api.example.com", "timeout" => 30, "retries" => 3 }

# Handle missing configurations
begin
  value = DBConfig.get(:missing_key)
rescue DBConfig::NotFoundError => e
  puts "Configuration not found: #{e.message}"
end
```

### Eager Loading

You can mark configurations for eager loading to improve performance:

```ruby
# Set eager loading flag
DBConfig.eager_load(:site_title, true)  # Enable eager loading
DBConfig.eager_load(:site_title, false) # Disable eager loading

# This will raise an error if the key doesn't exist
DBConfig.eager_load(:non_existent_key, true) # => DBConfig::NotFoundError
```

### Working with Keys

The gem works with both symbols and strings:

```ruby
DBConfig.set(:homepage_cta, "Click here!")
DBConfig.get(:homepage_cta)     # => "Click here!"
DBConfig.get("homepage_cta")    # => "Click here!"
```

## Error Handling

The gem provides specific error classes:

- `DBConfig::NotFoundError`: Raised when trying to access a non-existent configuration key

```ruby
begin
  value = DBConfig.get(:missing_config)
rescue DBConfig::NotFoundError => e
  # Handle missing configuration
  puts "Config not found: #{e.message}"
end
```

## Data Types

The gem automatically detects and preserves data types:

- **String**: Any text value
- **Integer**: Whole numbers
- **Float**: Decimal numbers
- **Boolean**: `true` or `false` values
- **Array**: Lists of values (stored as JSON)
- **Hash**: Key-value pairs (stored as JSON)

Values are stored as strings in the database but automatically converted back to their original type when retrieved. Complex data types (Arrays and Hashes) are serialized to JSON for storage and deserialized when retrieved.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/avo-hq/db_config.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
