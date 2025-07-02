require_relative "lib/db_config/version"

Gem::Specification.new do |spec|
  spec.name = "db_config"
  spec.version = DBConfig::VERSION
  spec.authors = ["Paul Bob"]
  spec.email = ["paul.ionut.bob@gmail.com"]
  spec.homepage = "https://github.com/avo-hq/db_config"
  spec.summary = "Database-backed configuration store for Rails applications"
  spec.description = "A Rails gem that provides a simple, database-backed configuration store with support for different data types, eager loading, and a clean API for managing application settings."
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
