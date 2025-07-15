class CreateDbConfig < ActiveRecord::Migration<%= "[#{ActiveRecord::Migration.current_version}]" if ActiveRecord::Migration.respond_to?(:current_version) %>
  def change
    create_table :db_config do |t|
      t.string :key, null: false
      t.string :value
      t.string :value_type, null: false, default: "String"
      t.boolean :eager_load, null: false, default: false

      t.timestamps null: false
    end

    add_index :db_config, :key, unique: true
    add_index :db_config, :eager_load
  end
end
