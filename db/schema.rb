# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160122045403) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "hstore"

  create_table "devices", force: :cascade do |t|
    t.integer  "user_id"
    t.string   "uuid"
    t.integer  "os"
    t.boolean  "mobile"
    t.string   "user_agent"
    t.string   "amqp_queue"
    t.string   "token_hash"
    t.datetime "last_request"
  end

  add_index "devices", ["token_hash"], name: "index_devices_on_token_hash", unique: true, using: :btree
  add_index "devices", ["user_id"], name: "index_devices_on_user_id", using: :btree

  create_table "feeds", force: :cascade do |t|
    t.string  "name",       null: false
    t.integer "feed_type",  null: false
    t.string  "amqp_xchg"
    t.integer "creator_id"
  end

  add_index "feeds", ["creator_id"], name: "index_feeds_on_creator_id", using: :btree
  add_index "feeds", ["name"], name: "index_feeds_on_name", unique: true, using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "user_id"
    t.integer  "feed_id"
    t.integer  "message_type"
    t.string   "payload"
    t.hstore   "options"
    t.datetime "sent_at"
    t.integer  "feed_sequence"
  end

  add_index "messages", ["feed_id"], name: "index_messages_on_feed_id", using: :btree
  add_index "messages", ["user_id"], name: "index_messages_on_user_id", using: :btree

  create_table "subscriptions", force: :cascade do |t|
    t.integer "user_id"
    t.integer "feed_id"
  end

  add_index "subscriptions", ["feed_id"], name: "index_subscriptions_on_feed_id", using: :btree
  add_index "subscriptions", ["user_id"], name: "index_subscriptions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.string   "amqp_xchg"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "username"
    t.string   "name"
  end

  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", unique: true, using: :btree

end
