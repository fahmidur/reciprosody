class ApplicationController < ActionController::Base
	require 'faye'

	# Part of Devise 3.0 + Rails 4 fix
	# before_filter :configure_devise_permitted_parameters, if: :devise_controller?

	before_filter :get_faye_url
	
	protect_from_forgery
	
	def help
		Helper.instance
	end
	
	
	class Helper
		include Singleton
		include ApplicationHelper
		include ActionView::Helpers::DateHelper
		include ActionView::Helpers::TextHelper
	end

	protected

	# Another Devise 3 Rails 4 fix
	# 01-28-2014
	# def configure_devise_permitted_parameters
	#     registration_params = [:name, :email, :password, :password_confirmation]

	#     if params[:action] == 'update'
	# 		devise_parameter_sanitizer.for(:account_update) { 
	# 			|u| u.permit(registration_params << :current_password)
	# 		}
	#     elsif params[:action] == 'create'
	# 		devise_parameter_sanitizer.for(:sign_up) { 
	# 			|u| u.permit(registration_params) 
	# 		}
	#     end
	# end

	# Yet another Rails 4.0 Fix
	# 01-28-2014
	def devise_parameter_sanitizer
		if resource_class == User
			UserSanitizer.new(User, :user, params)
		else
			super
		end
	end

	# creates a user#inbox messager
	# used to send any messages
	# through the inbox#messaging system
	def make_messager
		client = get_faye_client

		messager = Proc.new do |message|
			message_row = render_to_string(
				:partial => 'users/inbox_message', 
				:layout => false, 
				:locals => {:m => message}
			);

			client.publish("/messages/#{message.to.id}", {:message_row => message_row});
			Thread.new do
				unless message.to.getProp("inbox_block_emails")
					UsersMailer.message_mail(message.from, message.to, message.topic, message.body, message.id).deliver;
				end
				ActiveRecord::Base.connection.close
			end
		end
		return messager
	end

	# notify all users of a UserAction
	# through faye
	# this method takes a useraction
	# it is a callback for user_action_from
	# on all user_actionable resources
	def action_notify(ua)
		associated_users = ua.user_actionable.associated_users
		get_faye_client
		associated_users.each do |u|
			@faye_client.publish("/useraction/#{u.id}", {
				:html => render_to_string(
					:partial => 'users/user_action',
					:locals => {:ua => ua}
				),
				:id => ua.id
			});
		end
	end

	def get_faye_client
		logger.info "GET FAYE CLIENT"
		return @faye_client if @faye_client
		@faye_client = Faye::Client.new(get_faye_url)
		@faye_client.add_extension(FayeClientAugmenter.new)
		return @faye_client
	end

	def get_faye_url
		return @faye_url if @faye_url
		@faye_url = Rails.application.config.action_mailer.default_url_options[:host].clone


		if Rails.env == 'staging'
			@faye_url = 'faye.' + @faye_url
		else
			if @faye_url =~ /\:\d+$/
			@faye_url.gsub!(/\:\d+$/, ':9292')
			else
				@faye_url += ":9292"
			end
		end

		@faye_url = "http://#{@faye_url}/faye"
		return @faye_url
	end
end
