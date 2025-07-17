module DBConfig
  class ConfigRecord < ActiveRecord::Base
    self.table_name = "db_config"

    validates :key, presence: true, uniqueness: true
    validates :value_type, presence: true, inclusion: {in: %w[String Integer Float Boolean Array Hash NilClass]}
    validates :eager_load, inclusion: {in: [true, false]}

    # Sync cache automatically on any changes
    after_save :sync_cache
    after_destroy :sync_cache

    # Add index for the key column if not already present
    def self.ensure_indexes!
      unless connection.index_exists?(:db_config, :key)
        connection.add_index :db_config, :key, unique: true
      end
    end

    private

    def sync_cache
      # Only sync if Current attributes are available (i.e., in a request context)
      return unless defined?(DBConfig::Current)
      
      if destroyed?
        # Remove from cache if destroyed
        DBConfig::Current.cached_records.delete(key)
      else
        # Update cache with current record
        DBConfig::Current.cached_records[key] = self
      end
    end
  end
end
