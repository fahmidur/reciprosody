Reciprosody2::Application.configure do
  # Settings specified here will take precedence over those in config/application.rb

  # Don't care if the mailer can't send
  # config.action_mailer.raise_delivery_errors = false

  # Print deprecation notices to the Rails logger
  config.active_support.deprecation = :log

  # Only use best-standards-support built into browsers
  config.action_dispatch.best_standards_support = :builtin

  # Raise exception on mass assignment protection for Active Record models
  # config.active_record.mass_assignment_sanitizer = :strict

  # Log the query plan for queries taking more than this (works
  # with SQLite, MySQL, and PostgreSQL)
  # config.active_record.auto_explain_threshold_in_seconds = 0.5

  # Code is not reloaded between requests
  config.cache_classes = true
  config.eager_load = true
  # Full error reports are disabled and caching is turned on
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  # Disable Rails's static asset server (Apache or nginx will already do this)
  config.serve_static_assets = false
  # Compress JavaScripts and CSS
  config.assets.compress = true
  # Do fallback to assets pipeline if a precompiled asset is missed
  config.assets.compile = true
  # Generate digests for assets URLs
  config.assets.digest = true
  
	#SMTP Gmail Action Mailer - SFR
	#require 'tlsmail'
	#Net::SMTP.enable_tls(OpenSSL::SSL::VERIFY_NONE);
	
  config.faye_url = 'faye.reciprosody-staging.syedreza.org'
  config.action_mailer.default_url_options = { :host => 'reciprosody-staging.syedreza.org' }
  
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

  Paperclip.options[:command_path] = "/usr/bin"


end
