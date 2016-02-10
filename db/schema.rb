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

ActiveRecord::Schema.define(version: 20160210130217) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "bookmarks", force: :cascade do |t|
    t.integer  "user_id",       null: false
    t.string   "user_type"
    t.string   "document_id"
    t.string   "title"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.string   "document_type"
  end

  add_index "bookmarks", ["user_id"], name: "index_bookmarks_on_user_id", using: :btree

  create_table "collections", force: :cascade do |t|
    t.string    "slug",                               null: false
    t.integer   "repository_id"
    t.boolean   "dpla",               default: false, null: false
    t.boolean   "public",             default: false, null: false
    t.boolean   "in_georgia",         default: true,  null: false
    t.boolean   "remote",             default: false, null: false
    t.text      "display_title",                      null: false
    t.text      "short_description"
    t.text      "teaser"
    t.string    "color"
    t.integer   "other_repositories", default: [],    null: false, array: true
    t.text      "dc_title",           default: [],    null: false, array: true
    t.text      "dc_format",          default: [],    null: false, array: true
    t.text      "dc_publisher",       default: [],    null: false, array: true
    t.text      "dc_identifier",      default: [],    null: false, array: true
    t.text      "dc_rights",          default: [],    null: false, array: true
    t.text      "dc_contributor",     default: [],    null: false, array: true
    t.text      "dc_coverage_t",      default: [],    null: false, array: true
    t.text      "dc_coverage_s",      default: [],    null: false, array: true
    t.text      "dc_date",            default: [],    null: false, array: true
    t.text      "dc_source",          default: [],    null: false, array: true
    t.text      "dc_subject",         default: [],    null: false, array: true
    t.text      "dc_type",            default: [],    null: false, array: true
    t.text      "dc_description",     default: [],    null: false, array: true
    t.daterange "date_range"
    t.datetime  "created_at",                         null: false
    t.datetime  "updated_at",                         null: false
  end

  add_index "collections", ["dpla"], name: "index_collections_on_dpla", using: :btree
  add_index "collections", ["public"], name: "index_collections_on_public", using: :btree
  add_index "collections", ["repository_id"], name: "index_collections_on_repository_id", using: :btree
  add_index "collections", ["slug"], name: "index_collections_on_slug", unique: true, using: :btree

  create_table "items", force: :cascade do |t|
    t.string   "slug",                              null: false
    t.integer  "collection_id"
    t.boolean  "dpla",              default: false, null: false
    t.boolean  "public",            default: false, null: false
    t.integer  "other_collections", default: [],    null: false, array: true
    t.text     "dc_title",          default: [],    null: false, array: true
    t.text     "dc_format",         default: [],    null: false, array: true
    t.text     "dc_publisher",      default: [],    null: false, array: true
    t.text     "dc_identifier",     default: [],    null: false, array: true
    t.text     "dc_rights",         default: [],    null: false, array: true
    t.text     "dc_contributor",    default: [],    null: false, array: true
    t.text     "dc_coverage_t",     default: [],    null: false, array: true
    t.text     "dc_coverage_s",     default: [],    null: false, array: true
    t.text     "dc_date",           default: [],    null: false, array: true
    t.text     "dc_source",         default: [],    null: false, array: true
    t.text     "dc_subject",        default: [],    null: false, array: true
    t.text     "dc_type",           default: [],    null: false, array: true
    t.text     "dc_description",    default: [],    null: false, array: true
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
    t.text     "dc_creator",        default: [],    null: false, array: true
    t.text     "dc_language",       default: [],    null: false, array: true
    t.text     "dc_relation",       default: [],    null: false, array: true
  end

  add_index "items", ["collection_id"], name: "index_items_on_collection_id", using: :btree
  add_index "items", ["dpla"], name: "index_items_on_dpla", using: :btree
  add_index "items", ["public"], name: "index_items_on_public", using: :btree
  add_index "items", ["slug"], name: "index_items_on_slug", unique: true, using: :btree

  create_table "repositories", force: :cascade do |t|
    t.string   "slug",                              null: false
    t.boolean  "public",            default: false, null: false
    t.boolean  "in_georgia",        default: true,  null: false
    t.string   "title",                             null: false
    t.string   "color"
    t.string   "homepage_url"
    t.string   "directions_url"
    t.text     "teaser"
    t.text     "short_description"
    t.text     "description"
    t.text     "address"
    t.text     "strengths"
    t.text     "contact"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  add_index "repositories", ["slug"], name: "index_repositories_on_slug", unique: true, using: :btree

  create_table "searches", force: :cascade do |t|
    t.text     "query_params"
    t.integer  "user_id"
    t.string   "user_type"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
  end

  add_index "searches", ["user_id"], name: "index_searches_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.boolean  "guest",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "collections", "repositories"
  add_foreign_key "items", "collections"
end
