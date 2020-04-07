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

ActiveRecord::Schema.define(version: 2020_04_07_061006) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "activities", force: :cascade do |t|
    t.string "trackable_type", null: false
    t.integer "trackable_id", null: false
    t.string "action", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.index ["created_at"], name: "index_activities_on_created_at"
    t.index ["trackable_id", "trackable_type"], name: "index_activities_on_trackable_id_and_trackable_type"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "boards", force: :cascade do |t|
    t.string "name"
    t.integer "node_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["node_id"], name: "index_boards_on_node_id"
  end

  create_table "cards", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.date "due_date"
    t.integer "list_id"
    t.integer "previous_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["list_id"], name: "index_cards_on_list_id"
    t.index ["previous_id"], name: "index_cards_on_previous_id"
  end

  create_table "cards_users", id: false, force: :cascade do |t|
    t.integer "card_id", null: false
    t.integer "user_id", null: false
    t.index ["card_id", "user_id"], name: "index_cards_users_on_card_id_and_user_id"
    t.index ["user_id", "card_id"], name: "index_cards_users_on_user_id_and_card_id"
  end

  create_table "categories", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.text "content"
    t.string "commentable_type"
    t.integer "commentable_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "configurations", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_configurations_on_name", unique: true
  end

  create_table "evidence", force: :cascade do |t|
    t.integer "node_id"
    t.integer "issue_id"
    t.text "content"
    t.string "author"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["issue_id"], name: "index_evidence_on_issue_id"
    t.index ["node_id"], name: "index_evidence_on_node_id"
  end

  create_table "lists", force: :cascade do |t|
    t.string "name"
    t.integer "board_id"
    t.integer "previous_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["board_id"], name: "index_lists_on_board_id"
    t.index ["previous_id"], name: "index_lists_on_previous_id"
  end

  create_table "logs", force: :cascade do |t|
    t.integer "uid"
    t.text "text"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nodes", force: :cascade do |t|
    t.integer "type_id"
    t.string "label"
    t.integer "parent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.text "properties"
    t.integer "children_count", default: 0, null: false
    t.index ["parent_id"], name: "index_nodes_on_parent_id"
    t.index ["type_id"], name: "index_nodes_on_type_id"
  end

  create_table "notes", force: :cascade do |t|
    t.string "author"
    t.text "text"
    t.integer "node_id"
    t.integer "category_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_notes_on_category_id"
    t.index ["node_id"], name: "index_notes_on_node_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.string "action"
    t.datetime "read_at"
    t.string "notifiable_type"
    t.integer "notifiable_id"
    t.integer "actor_id"
    t.integer "recipient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable_type_and_notifiable_id"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
  end

  create_table "subscriptions", force: :cascade do |t|
    t.string "subscribable_type"
    t.integer "subscribable_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["subscribable_id", "subscribable_type", "user_id"], name: "index_subscriptions_on_subscribablue_and_user", unique: true
    t.index ["subscribable_type", "subscribable_id"], name: "index_subscriptions_on_subscribable_type_and_subscribable_id"
    t.index ["user_id"], name: "index_subscriptions_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.integer "tag_id"
    t.string "taggable_type"
    t.integer "taggable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["tag_id", "taggable_id", "taggable_type"], name: "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", unique: true
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
    t.index ["taggable_type", "taggable_id"], name: "index_taggings_on_taggable_type_and_taggable_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name", null: false
    t.integer "taggings_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name"
    t.index ["taggings_count"], name: "index_tags_on_taggings_count"
  end

  create_table "users", force: :cascade do |t|
    t.string "email"
    t.string "password_hash"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "preferences"
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.integer "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object", limit: 1073741823
    t.datetime "created_at"
    t.integer "project_id"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
    t.index ["project_id"], name: "index_versions_on_project_id"
  end

end
