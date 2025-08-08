require "rails/railtie"
require "db_config/middleware"

module DBConfig
  class Railtie < ::Rails::Railtie
    railtie_name :db_config

    def self.root
      @root ||= Pathname.new(File.expand_path('../..', __dir__))
    end

    rake_tasks do
      load "tasks/db_config_tasks.rake"
    end

    generators do
      require "generators/db_config/install/install_generator"
    end

    initializer "db_config.load_app_instance_data" do |app|
      # This can be used for any setup that needs to happen after Rails is loaded
    end

    initializer "db_config.autoload" do |app|
      if defined?(Avo)
        db_config_app_directory = DBConfig::Railtie.root.join("app/avo").to_s
        db_config_avo_controllers_directory = DBConfig::Railtie.root.join("app/controllers/avo").to_s
        
        ActiveSupport::Dependencies.autoload_paths.delete(db_config_app_directory)

        Rails.autoloaders.main.push_dir(db_config_app_directory, namespace: Avo)
        Rails.autoloaders.main.push_dir(db_config_avo_controllers_directory, namespace: Avo)
      end
    end

    initializer "db_config.add_middleware" do |app|
      app.middleware.use DBConfig::Middleware
    end
  end
end
