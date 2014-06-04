source 'https://rubygems.org'

gem 'rails', '4.0.2'

gem 'sqlite3'
gem 'puma' # 07-22-2013
gem 'thin'
gem 'faye'
gem 'faye-rails' # sfr: to get rid of second server, host on thin
gem 'passenger'
gem 'eventmachine'
gem 'kaminari'


gem 'uglifier', '>= 1.0.3'
gem 'less-rails', '2.3.3'
gem 'therubyracer'

gem 'jquery-rails', '2.1.4'

#---Modified by Me -SFR----------------
gem 'twitter-bootstrap-rails', '2.2.7'  # Needed for Glyphicons to work
gem 'devise', '3.0.0'                   # Must be specifically set to 3.0.0
gem "recaptcha", :require => "recaptcha/rails"
gem 'nifty-generators'
gem "rails3-jquery-autocomplete"

gem "redcarpet", "1.17.2"
gem "nokogiri"
gem 'acts_as_commentable_with_threading'
gem 'carrierwave'
gem 'waveinfo'

gem 'bibtex-ruby', :require => 'bibtex'
gem 'csl', '1.2.1', :require => 'csl'
gem 'csl-styles', :require => 'csl/styles'
gem 'citeproc-ruby', :require => 'citeproc'

gem 'mail_view', '~> 1.0.3'
gem 'simplecov', :require => false, :group => :test

gem 'paperclip', '~> 3.0'
gem 'fog'
#---------------------------------------------



group :production do
  gem "mysql2"
end

group :development, :test do
  gem 'capistrano'

  gem "factory_girl_rails", "~> 4.0"
  
  gem "capybara"
  gem 'rspec' # for cucumber
  gem 'cucumber-rails', :require => false
  gem 'database_cleaner'
  gem 'rails-erd'
end

#--------------------------------------




# 01-28-2014
# Rails 4 fix for this as of 13 days ago
# The downside to being too bleeding edge
# https://github.com/LTe/acts-as-messageable/issues/57
# gem 'acts-as-messageable', :git => 'git://github.com/hoczaj/acts-as-messageable.git'
gem 'acts-as-messageable', :git => 'https://github.com/fahmidur/acts-as-messageable'

# Added by SFR for Rails 4.0 transition
gem "activerecord-session_store"
gem "protected_attributes"
