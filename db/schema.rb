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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20130124191935) do

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",   :default => 0
    t.string   "commentable_type", :default => ""
    t.string   "title",            :default => ""
    t.text     "body",             :default => ""
    t.string   "subject",          :default => ""
    t.integer  "user_id",          :default => 0,  :null => false
    t.integer  "parent_id"
    t.integer  "lft"
    t.integer  "rgt"
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "comments", ["commentable_id"], :name => "index_comments_on_commentable_id"
  add_index "comments", ["user_id"], :name => "index_comments_on_user_id"

  create_table "corpora", :force => true do |t|
    t.string   "name"
    t.string   "language"
    t.text     "description"
    t.datetime "created_at",   :null => false
    t.datetime "updated_at",   :null => false
    t.string   "utoken"
    t.integer  "duration"
    t.integer  "num_speakers"
    t.string   "speaker_desc"
    t.string   "genre"
    t.string   "annotation"
    t.string   "license"
    t.text     "citation"
  end

  create_table "faq_questions", :force => true do |t|
    t.text     "question"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "languages", :force => true do |t|
    t.string "name"
  end

  create_table "licenses", :force => true do |t|
    t.string "name"
  end

  create_table "memberships", :force => true do |t|
    t.integer  "user_id"
    t.integer  "corpus_id"
    t.string   "role"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "publication_corpora_relationship", :force => true do |t|
    t.integer  "publication_id"
    t.integer  "corpus_id"
    t.string   "name"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "publication_corpora_relationship", ["corpus_id"], :name => "index_publication_corpora_relationship_on_corpus_id"
  add_index "publication_corpora_relationship", ["publication_id"], :name => "index_publication_corpora_relationship_on_publication_id"

  create_table "publication_memberships", :force => true do |t|
    t.string   "role"
    t.integer  "user_id"
    t.integer  "publication_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  add_index "publication_memberships", ["publication_id"], :name => "index_publication_memberships_on_publication_id"
  add_index "publication_memberships", ["user_id"], :name => "index_publication_memberships_on_user_id"

  create_table "publications", :force => true do |t|
    t.string   "name"
    t.text     "keywords"
    t.text     "description"
    t.text     "authors"
    t.string   "url"
    t.string   "local"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.text     "citation"
    t.text     "venue"
    t.datetime "pubdate"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id", :null => false
    t.text     "data"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "super_keys", :force => true do |t|
    t.integer  "user_id"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "super_keys", ["user_id"], :name => "index_super_keys_on_user_id"

  create_table "users", :force => true do |t|
    t.string   "email",                                 :default => "", :null => false
    t.string   "encrypted_password",                    :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                         :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.datetime "created_at",                                            :null => false
    t.datetime "updated_at",                                            :null => false
    t.string   "name",                   :limit => 100
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
