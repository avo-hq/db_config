module DBConfig
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      # Load eager configs for this request
      DBConfig::Current.load_eager_configs!
      
      # Continue with the request
      @app.call(env)
    end
  end
end 