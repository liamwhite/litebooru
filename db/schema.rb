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

ActiveRecord::Schema.define(version: 20150906212018) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "comments", force: :cascade do |t|
    t.string   "body",              default: "",    null: false
    t.boolean  "hidden_from_users", default: false
    t.time     "deleted_at"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.integer  "user_id"
    t.integer  "image_id"
    t.integer  "deleted_by_id"
    t.inet     "ip"
    t.string   "user_agent"
    t.boolean  "anonymous"
  end

  add_index "comments", ["created_at"], name: "index_comments_on_created_at", using: :btree
  add_index "comments", ["image_id", "created_at"], name: "index_comments_on_image_id_and_created_at", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "source_url"
    t.string   "description"
    t.integer  "id_number",         default: 0
    t.boolean  "hidden_from_users"
    t.string   "hide_reason"
    t.integer  "comment_count"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "tag_ids",                                    array: true
    t.integer  "user_id"
    t.integer  "hidden_by_user_id"
    t.integer  "watcher_ids",                                array: true
    t.inet     "ip"
    t.string   "user_agent"
    t.boolean  "anonymous"
  end

  add_index "images", ["hidden_from_users"], name: "index_images_on_hidden_from_users", using: :btree
  add_index "images", ["id_number"], name: "index_images_on_id_number", unique: true, using: :btree
  add_index "images", ["tag_ids"], name: "index_images_on_tag_ids", using: :gin

  create_table "notifications", force: :cascade do |t|
    t.string   "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer  "user_id"
    t.integer  "actor_id"
  end

  add_index "notifications", ["user_id", "created_at"], name: "index_notifications_on_user_id_and_created_at", using: :btree

  create_table "reports", force: :cascade do |t|
    t.string   "reason"
    t.boolean  "open"
    t.string   "state"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "user_id"
    t.integer  "admin_id"
    t.integer  "reportable_id"
    t.string   "reportable_type"
    t.inet     "ip"
    t.string   "user_agent"
  end

  create_table "tags", force: :cascade do |t|
    t.string   "description"
    t.integer  "image_count"
    t.string   "name"
    t.string   "namespace"
    t.string   "name_in_namespace"
    t.string   "short_descripion"
    t.boolean  "system"
    t.string   "slug"
    t.datetime "created_at",        null: false
    t.datetime "updated_at",        null: false
  end

  add_index "tags", ["name"], name: "index_tags_on_name", using: :btree
  add_index "tags", ["slug"], name: "index_tags_on_slug", using: :btree
  add_index "tags", ["system"], name: "index_tags_on_system", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "name",                                 null: false
    t.string   "downcase_name",                        null: false
    t.string   "slug"
    t.string   "email",                   default: "", null: false
    t.string   "encrypted_password",      default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",           default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "unread_notification_ids",                           array: true
  end

  add_index "users", ["downcase_name"], name: "index_users_on_downcase_name", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["name"], name: "index_users_on_name", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["slug"], name: "index_users_on_slug", using: :btree
  add_index "users", ["unread_notification_ids"], name: "index_users_on_unread_notification_ids", using: :gin

end
