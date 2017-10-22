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

ActiveRecord::Schema.define(version: 20171022145339) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "hot_catch_apps", force: :cascade do |t|
    t.string   "name",       null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "main_hot_catch_logs", force: :cascade do |t|
    t.text     "log_data",                     null: false
    t.integer  "count_log",        default: 1, null: false
    t.string   "from_log",                     null: false
    t.string   "status",                       null: false
    t.integer  "hot_catch_app_id"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.index ["hot_catch_app_id"], name: "index_main_hot_catch_logs_on_hot_catch_app_id", using: :btree
  end

  create_table "role_users", force: :cascade do |t|
    t.integer  "role_id",    null: false
    t.integer  "user_id",    null: false
    t.json     "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_role_users_on_role_id", using: :btree
    t.index ["user_id"], name: "index_role_users_on_user_id", using: :btree
  end

  create_table "roles", force: :cascade do |t|
    t.string   "name",       null: false
    t.string   "info",       null: false
    t.text     "full_info",  null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["info"], name: "index_roles_on_info", unique: true, using: :btree
    t.index ["name"], name: "index_roles_on_name", unique: true, using: :btree
  end

  create_table "user_requests", force: :cascade do |t|
    t.string   "ip",                    null: false
    t.datetime "request_time",          null: false
    t.integer  "main_hot_catch_log_id"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.index ["main_hot_catch_log_id"], name: "index_user_requests_on_main_hot_catch_log_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                           null: false
    t.string   "crypted_password"
    t.string   "salt"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "failed_logins_count", default: 0
    t.datetime "lock_expires_at"
    t.string   "unlock_token"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", using: :btree
  end

  add_foreign_key "main_hot_catch_logs", "hot_catch_apps"
  add_foreign_key "role_users", "roles"
  add_foreign_key "role_users", "users"
  add_foreign_key "user_requests", "main_hot_catch_logs"
end
