Reciprosody2::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # In the development environment your application's code is reloaded on
  # every request. This slows down response time but is perfect for development
  # since you don't have to restart the web server when you make code changes.
  config.cache_classes = false

  # Log error messages when you accidentally call methods on nil.
  config.whiny_nils = true

  # Show full error reports and disable caching
  config.consider_all_requests_local       = true
  config.action_controller.perform_caching = false

  # Don't care if the mailer can't send
  # config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  config.active_record.auto_explain_threshold_in_seconds = 0.5

  #-ASSETS-
  config.assets.compress = false
  config.assets.enabled = true
  config.assets.debug = true
  config.serve_static_assets = true #Prevents precompiled assets being included twice - SFR
  # Generate digests for assets URLs.
  config.assets.digest = true
  
	#SMTP Gmail Action Mailer - SFR
	#require 'tlsmail'
	#Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE);
	
  #-SFR Home Server
	# config.action_mailer.default_url_options = { :host => '108.29.43.202:3000' }
	
	#-Localhost for Testing
  config.action_mailer.default_url_options = { :host => 'localhost:3000' }
	# config.action_mailer.default_url_options = { :host => '192.168.1.2:3000' }
	
	#-Development machine i.e Jaguare
	#config.action_mailer.default_url_options = { :host => `curl ifconfig.me`+":3000" }
  
	config.action_mailer.delivery_method = :smtp
	config.action_mailer.perform_deliveries = true
	config.action_mailer.raise_delivery_errors = true

  
	config.action_mailer.smtp_settings = {
    :enable_starttls_auto   => true,
    :address		            => "smtp.gmail.com",
    :port 			            => "587",
    :authenticaton          => :plain,
    :user_name              => "WebDevMailer1@gmail.com",
    :password               => "itdoesnotmatter",
    :host                   => "localhost:3000" 
 }

  # config.action_mailer.smtp_settings = {
  #     :enable_starttls_auto => true,
  #     :address => "mail.reciprosody.org",
  #     :port => "25",
  #     :authenticaton => :none,
  #     :host => "localhost:3000"
  # }

  # Above results in:
	# SocketError (getaddrinfo: Name or service not known)
  # 

  Paperclip.options[:command_path] = "/usr/bin"
  # config.paperclip_defaults = {
  #   :storage => :fog, 
  #   :fog_credentials => {
  #     :provider => "Local", 
  #     :local_root => "#{Rails.root}/public"
  #   }, 
  #   :fog_directory => "", 
  #   :fog_host => "localhost"
  # }


end
