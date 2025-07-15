module DBConfig
  class ConfigRecord < ActiveRecord::Base
    self.table_name = "db_config"

    validates :key, presence: true, uniqueness: true
    validates :value_type, presence: true, inclusion: {in: %w[String Integer Float Boolean Array Hash NilClass]}
    validates :eager_load, inclusion: {in: [true, false]}

    # Add index for the key column if not already present
    def self.ensure_indexes!
      unless connection.index_exists?(:db_config, :key)
        connection.add_index :db_config, :key, unique: true
      end
    end
  end
end
