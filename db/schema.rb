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

ActiveRecord::Schema.define(version: 20140502070908) do

  create_table "comments", force: true do |t|
    t.integer  "commentable_id",   default: 0
    t.string   "commentable_type", default: ""
    t.string   "title",            default: ""
    t.text     "body",             default: ""
    t.string   "subject",          default: ""
    t.integer  "user_id",          default: 0,  null: false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
  end

  add_index "comments", ["commentable_id"], name: "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], name: "index_comments_on_user_id"

  create_table "corpora", force: true do |t|
    t.string   "name"
    t.string   "language"
    t.text     "description"
    t.datetime "created_at",   null: false
    t.datetime "updated_at",   null: false
    t.string   "utoken"
    t.integer  "duration"
    t.integer  "num_speakers"
    t.string   "speaker_desc"
    t.string   "genre"
    t.string   "annotation"
    t.string   "license"
    t.text     "citation"
  end

  create_table "faq_questions", force: true do |t|
    t.text     "question"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "institutions", force: true do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "languages", force: true do |t|
    t.string "name"
  end

  create_table "licenses", force: true do |t|
    t.string "name"
  end

  create_table "memberships", force: true do |t|
    t.integer  "user_id"
    t.integer  "corpus_id"
    t.string   "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "messages", force: true do |t|
    t.string   "topic"
    t.text     "body"
    t.integer  "received_messageable_id"
    t.string   "received_messageable_type"
    t.integer  "sent_messageable_id"
    t.string   "sent_messageable_type"
    t.boolean  "opened",                     default: false
    t.boolean  "recipient_delete",           default: false
    t.boolean  "sender_delete",              default: false
    t.datetime "created_at",                                 null: false
    t.datetime "updated_at",                                 null: false
    t.string   "ancestry"
    t.boolean  "recipient_permanent_delete", default: false
    t.boolean  "sender_permanent_delete",    default: false
  end

  add_index "messages", ["ancestry"], name: "index_messages_on_ancestry"
  add_index "messages", ["sent_messageable_id", "received_messageable_id"], name: "acts_as_messageable_ids"

  create_table "programming_languages", force: true do |t|
    t.string "name"
  end

  create_table "publication_corpora_relationship", force: true do |t|
    t.integer  "publication_id"
    t.integer  "corpus_id"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "publication_corpora_relationship", ["corpus_id"], name: "index_publication_corpora_relationship_on_corpus_id"
  add_index "publication_corpora_relationship", ["publication_id"], name: "index_publication_corpora_relationship_on_publication_id"

  create_table "publication_keywords", force: true do |t|
    t.string "name"
  end

  create_table "publication_memberships", force: true do |t|
    t.string   "role"
    t.integer  "user_id"
    t.integer  "publication_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "publication_memberships", ["publication_id"], name: "index_publication_memberships_on_publication_id"
  add_index "publication_memberships", ["user_id"], name: "index_publication_memberships_on_user_id"

  create_table "publications", force: true do |t|
    t.string   "name"
    t.text     "keywords"
    t.text     "description"
    t.text     "authors"
    t.string   "url"
    t.string   "local"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
    t.text     "citation"
    t.text     "venue"
    t.datetime "pubdate"
  end

  create_table "resource_types", force: true do |t|
    t.string "name"
  end

  create_table "resumable_incomplete_uploads", force: true do |t|
    t.string   "filename"
    t.string   "identifier"
    t.integer  "user_id"
    t.string   "url"
    t.text     "formdata"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "resumable_incomplete_uploads", ["user_id"], name: "index_resumable_incomplete_uploads_on_user_id"

  create_table "search_log_entries", force: true do |t|
    t.integer  "user_id"
    t.integer  "resource_type_id"
    t.string   "input"
    t.text     "output"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "search_log_entries", ["resource_type_id"], name: "index_search_log_entries_on_resource_type_id"
  add_index "search_log_entries", ["user_id"], name: "index_search_log_entries_on_user_id"

  create_table "sessions", force: true do |t|
    t.string   "session_id", null: false
    t.text     "data"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "sessions", ["session_id"], name: "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], name: "index_sessions_on_updated_at"

  create_table "super_key_requests", force: true do |t|
    t.string   "token"
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "super_key_requests", ["user_id"], name: "index_super_key_requests_on_user_id"

  create_table "super_keys", force: true do |t|
    t.integer  "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "super_keys", ["user_id"], name: "index_super_keys_on_user_id"

  create_table "tool_corpora_relationship", force: true do |t|
    t.integer  "tool_id"
    t.integer  "corpus_id"
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tool_corpora_relationship", ["corpus_id"], name: "index_tool_corpora_relationship_on_corpus_id"
  add_index "tool_corpora_relationship", ["tool_id"], name: "index_tool_corpora_relationship_on_tool_id"

  create_table "tool_keywords", force: true do |t|
    t.string "name"
  end

  create_table "tool_memberships", force: true do |t|
    t.integer  "tool_id"
    t.integer  "user_id"
    t.string   "role"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "tool_memberships", ["tool_id"], name: "index_tool_memberships_on_tool_id"
  add_index "tool_memberships", ["user_id"], name: "index_tool_memberships_on_user_id"

  create_table "tool_publication_relationships", force: true do |t|
    t.integer  "tool_id"
    t.integer  "publication_id"
    t.string   "name"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "tool_publication_relationships", ["publication_id"], name: "index_tool_publication_relationships_on_publication_id"
  add_index "tool_publication_relationships", ["tool_id"], name: "index_tool_publication_relationships_on_tool_id"

  create_table "tools", force: true do |t|
    t.string   "name"
    t.string   "programming_language"
    t.string   "license"
    t.string   "url"
    t.text     "authors"
    t.text     "description"
    t.text     "keywords"
    t.string   "local"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "user_action_types", force: true do |t|
    t.string "name"
    t.text   "desc"
  end

  create_table "user_actions", force: true do |t|
    t.integer  "user_id"
    t.integer  "user_action_type_id"
    t.integer  "user_actionable_id"
    t.string   "user_actionable_type"
    t.string   "ip_address"
    t.float    "lat"
    t.float    "lon"
    t.integer  "version"
    t.text     "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_institution_relationships", force: true do |t|
    t.integer  "user_id"
    t.integer  "institution_id"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
  end

  add_index "user_institution_relationships", ["institution_id"], name: "index_user_institution_relationships_on_institution_id"
  add_index "user_institution_relationships", ["user_id"], name: "index_user_institution_relationships_on_user_id"

  create_table "user_properties", force: true do |t|
    t.integer  "user_id"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_index "user_properties", ["user_id"], name: "index_user_properties_on_user_id"

  create_table "users", force: true do |t|
    t.string   "email",                              default: "", null: false
    t.string   "encrypted_password",                 default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "name",                   limit: 100
    t.string   "avatar_file_name"
    t.string   "avatar_content_type"
    t.integer  "avatar_file_size"
    t.datetime "avatar_updated_at"
    t.string   "gravatar_email"
  end

  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
