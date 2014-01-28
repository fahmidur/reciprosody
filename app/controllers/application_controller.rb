class ApplicationController < ActionController::Base
	require 'faye'

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
		if @faye_url =~ /\:\d+$/
			@faye_url.gsub!(/\:\d+$/, ':9292')
		else
			@faye_url += ":9292"
		end
		@faye_url = "http://#{@faye_url}/faye"
		return @faye_url
	end
end
