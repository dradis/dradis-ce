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

ActiveRecord::Schema.define(version: 20151125115836) do

  create_table "activities", force: :cascade do |t|
    t.string   "user",           null: false
    t.string   "trackable_type", null: false
    t.integer  "trackable_id",   null: false
    t.string   "action",         null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "activities", ["created_at"], name: "index_activities_on_created_at"
  add_index "activities", ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"

  create_table "categories", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "configurations", force: :cascade do |t|
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "configurations", ["name"], name: "index_configurations_on_name", unique: true

  create_table "evidence", force: :cascade do |t|
    t.integer  "node_id"
    t.integer  "issue_id"
    t.text     "content"
    t.string   "author"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "evidence", ["issue_id"], name: "index_evidence_on_issue_id"
  add_index "evidence", ["node_id"], name: "index_evidence_on_node_id"

  create_table "logs", force: :cascade do |t|
    t.integer  "uid"
    t.text     "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "nodes", force: :cascade do |t|
    t.integer  "type_id"
    t.string   "label"
    t.integer  "parent_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "position"
    t.text     "properties"
  end

  add_index "nodes", ["parent_id"], name: "index_nodes_on_parent_id"
  add_index "nodes", ["type_id"], name: "index_nodes_on_type_id"

  create_table "notes", force: :cascade do |t|
    t.string   "author"
    t.text     "text"
    t.integer  "node_id"
    t.integer  "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "notes", ["category_id"], name: "index_notes_on_category_id"
  add_index "notes", ["node_id"], name: "index_notes_on_node_id"

  create_table "taggings", force: :cascade do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], name: "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", unique: true
  add_index "taggings", ["tag_id"], name: "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"

  create_table "tags", force: :cascade do |t|
    t.string   "name",                       null: false
    t.integer  "taggings_count", default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "tags", ["name"], name: "index_tags_on_name"
  add_index "tags", ["taggings_count"], name: "index_tags_on_taggings_count"

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",                     null: false
    t.integer  "item_id",                       null: false
    t.string   "event",                         null: false
    t.string   "whodunnit"
    t.text     "object",     limit: 1073741823
    t.datetime "created_at"
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"

end
