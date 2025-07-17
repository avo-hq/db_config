module DBConfig
  class Current < ActiveSupport::CurrentAttributes
    attribute :cached_records, default: {}

    def load_eager_configs!
      self.cached_records = DBConfig::ConfigRecord.where(eager_load: true).index_by(&:key)
    end
  end
end 