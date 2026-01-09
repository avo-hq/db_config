module DBConfig
  class Record < ActiveRecord::Base
    self.table_name_prefix = "db_config_"

    VALUE_TYPES = %w[String Integer Float Boolean Array Hash NilClass]

    validates :key, presence: true, uniqueness: true
    validates :value_type, presence: true, inclusion: {in: VALUE_TYPES}
    validates :eager_load, inclusion: {in: [true, false]}

    # Sync cache automatically on any changes
    after_save :sync_cache
    after_destroy :sync_cache

    def self.ransackable_attributes(auth_object = nil)
      authorizable_ransackable_attributes
    end

    def self.ransackable_associations(auth_object = nil)
      authorizable_ransackable_associations
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
