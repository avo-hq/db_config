require "rails/generators"
require "rails/generators/active_record"

module DbConfig
  module Generators
    class InstallGenerator < Rails::Generators::Base
      include ActiveRecord::Generators::Migration

      source_root File.expand_path("templates", __dir__)
      desc "Creates a DBConfig migration and shows usage information"

      def copy_migration
        migration_template "create_db_config.rb", File.join(db_migrate_path, "create_db_config.rb")
      end

      def show_usage
        say ""
        say "=" * 70
        say "DB_CONFIG INSTALLATION COMPLETE", :green
        say "=" * 70
        say ""
        say "Run the migration:"
        say "  rails db:migrate", :yellow
        say ""
        say "Usage examples:", :green
        say ""
        say "  # Set different types of configuration values"
        say "  DBConfig.set(:homepage_cta, 'Click here now!')", :cyan
        say "  DBConfig.set(:max_users, 1000)", :cyan
        say "  DBConfig.set(:maintenance_mode, false)", :cyan
        say "  DBConfig.set(:allowed_countries, ['US', 'CA', 'UK'])", :cyan
        say "  DBConfig.set(:api_config, { endpoint: 'api.com', timeout: 30 })", :cyan
        say ""
        say "  # Get configuration values (returns original data type)"
        say "  DBConfig.get(:homepage_cta)", :cyan
        say "  # => 'Click here now!'"
        say "  DBConfig.get(:allowed_countries)", :cyan
        say "  # => ['US', 'CA', 'UK']"
        say ""
        say "  # Get with default values (creates key if not found)"
        say "  DBConfig.get(:page_size, default: 25)", :cyan
        say "  DBConfig.get(:debug_mode, default: false)", :cyan
        say "  DBConfig.get(:admin_emails, default: [])", :cyan
        say ""
        say "  # Enable/disable eager loading for a config"
        say "  DBConfig.eager_load(:homepage_cta, true)", :cyan
        say ""
        say "  # Handle missing configs"
        say "  begin"
        say "    DBConfig.get(:missing_key)"
        say "  rescue DBConfig::NotFoundError => e"
        say "    puts e.message"
        say "  end", :cyan
        say ""
        say "Supported data types: String, Integer, Float, Boolean, Array, Hash", :green
        say "Default values: Automatically create missing keys with provided defaults", :green
        say ""
        say "=" * 70
      end

      private

      def db_migrate_path
        configured_migrate_path || default_migrate_path
      end

      def configured_migrate_path
        Rails.application.config.paths["db/migrate"]&.first
      end

      def default_migrate_path
        Rails.root.join("db", "migrate")
      end
    end
  end
end
