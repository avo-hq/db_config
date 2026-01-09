# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 1) do
  create_table "db_config_records", force: :cascade do |t|
    t.string "key", null: false
    t.string "value"
    t.string "value_type", default: "string", null: false
    t.boolean "eager_load", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["eager_load"], name: "index_db_config_records_on_eager_load"
    t.index ["key"], name: "index_db_config_records_on_key", unique: true
  end
end
