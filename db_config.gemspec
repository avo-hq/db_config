require_relative "lib/db_config/version"

Gem::Specification.new do |spec|
  spec.name = "db_config"
  spec.version = DBConfig::VERSION
  spec.authors = ["Paul Bob"]
  spec.email = ["paul.ionut.bob@gmail.com"]
  spec.homepage = "https://github.com/avo-hq/db_config"
  spec.summary = "Database-backed configuration store for Rails with automatic type conversion, eager loading, and Avo integration"
  spec.description = <<~DESC
    DBConfig provides a powerful, database-backed configuration store for Rails applications.
    Store and retrieve configuration values dynamically with automatic type detection and conversion
    (strings, integers, floats, booleans, arrays, hashes, and nil). Features eager loading for
    high-performance access to frequently used configs, a simple API (get/set/update/delete),
    and seamless integration with Avo admin panels.

    See https://github.com/avo-hq/db_config for full documentation and usage examples.
  DESC
  spec.license = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the "allowed_push_host"
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  spec.metadata["allowed_push_host"] = "https://rubygems.pkg.github.com/avo-hq"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/avo-hq/db_config"
  spec.metadata["changelog_uri"] = "https://github.com/avo-hq/db_config/blob/main/CHANGELOG.md"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "activerecord", ">= 6.0"
  spec.add_dependency "railties", ">= 6.0"
  spec.add_dependency "activesupport", ">= 6.0"
end
