# Be sure to restart your server when you modify this file.

# Reciprosody2::Application.config.session_store :cookie_store, key: '_Reciprosody2_session'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rails generate session_migration")
Reciprosody2::Application.config.session_store :active_record_store

# Added to deal with Rails 4.0 + activerecordsession_store
# https://github.com/rails/activerecord-session_store/issues/6
ActiveRecord::SessionStore::Session.attr_accessible :data, :session_id
