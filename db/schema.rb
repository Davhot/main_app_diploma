# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170816124804) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "main_hot_catch_logs", force: :cascade do |t|
    t.text     "log_data",                      null: false
    t.integer  "count_log",         default: 1, null: false
    t.integer  "id_log_origin_app",             null: false
    t.string   "name_app",                      null: false
    t.string   "from_log",                      null: false
    t.string   "status"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.index ["id_log_origin_app", "name_app"], name: "index_main_hot_catch_logs_on_id_log_origin_app_and_name_app", unique: true, using: :btree
  end

end
