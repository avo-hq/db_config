require "rails/railtie"
require "db_config/middleware"

module DBConfig
  class Railtie < ::Rails::Railtie
    railtie_name :db_config

    rake_tasks do
      load "tasks/db_config_tasks.rake"
    end

    generators do
      require "generators/db_config/install/install_generator"
    end

    initializer "db_config.load_app_instance_data" do |app|
      # This can be used for any setup that needs to happen after Rails is loaded
    end

    initializer "db_config.add_middleware" do |app|
      app.middleware.use DBConfig::Middleware
    end
  end
end
