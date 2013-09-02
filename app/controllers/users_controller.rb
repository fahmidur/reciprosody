class UsersController < ApplicationController
	require 'faye'
	require 'eventmachine'

	protect_from_forgery
	before_filter :auth

	
	#GET /users/mixed_search
	#params[:q] = query
	def mixed_search
		q = params[:q]
		unless q && q.length > 2
			render :json => []
			return
		end

		q = "%#{q}%"
		render :json => User.where("name LIKE ? OR email LIKE ?", q, q)-[current_user()]
	end

	# GET /user/inbox_get
	# params[:mid] = message id
	def inbox_get
		@user = current_user()
		mid = params[:mid]

		unless mid && mid =~ /^\d+$/
			render :json => {:ok => false, :mid => mid, :error => 'message id not valid'}
			return
		end

		mid = mid.to_i

		messages = @user.messages.with_id(mid) + @user.deleted_messages.with_id(mid)
		message = messages[0] unless messages.length == 0

		unless message
			render :json => {:ok => false, :mid => mid, :error => 'message not found'}
			return
		end

		render :json => {
			:ok => true, 
			:mid => mid,
			:from => message.from, 
			:to => message.to, 
			:topic => message.topic, 
			:body => message.body, 
			:created => message.created_at,
			:time_ago => help.time_ago_in_words(message.created_at),
		}
	end

	# GET /user/inbox_restore
	def inbox_restore
		@user = current_user()
		mids = params[:mids]
		unless mids
			render :json => {:ok => false, :error => 'mids missing'}
			return
		end

		mids_hash = nl_ids_to_hash(mids)

		found = 0
		@user.deleted_messages.process do |m|
			if mids_hash[m.id]
				m.restore
				found += 1
			end
		end
		readed = @user.received_messages.readed.size
		unreaded = @user.received_messages.unreaded.size

		render :json => {:ok => true, :mids => mids, :found => found, :readed => readed, :unreaded => unreaded}
	end

	# GET /user/inbox_mark_unread
	def inbox_mark_unread
		@user = current_user()
		mids = params[:mids]
		unless mids
			render :json => {:ok => false, :error => 'mids missing'}
			render
		end

		mids_hash = nl_ids_to_hash(mids)
		found = 0
		@user.messages.readed.process do |m|
			if mids_hash[m.id]
				m.mark_as_unread
				found += 1
			end
		end

		render :json => {:ok => true, :mids => mids, :found => found}
	end
	# GET /user/inbox_mark_read
	# params[:mids] = message ids (newline separated)
	def inbox_mark_read
		@user = current_user()
		mids = params[:mids]
		unless mids
			render :json => {:ok => false, :error => 'mids missing'}
			return
		end

		mids_hash = nl_ids_to_hash(mids)

		found = 0
		@user.messages.unreaded.process do |m|
			if mids_hash[m.id]
				m.mark_as_read 
				found += 1
			end
		end

		render :json => {:ok => true, :mids => mids, :found => found}
	end

	# GET /user/inbox_delete
	# params[:mids] = message ids (newline separated)
	def inbox_delete
		@user = current_user()
		mids = params[:mids]
		unless mids
			render :json => {:ok => false, :error => 'mids missing'}
			return
		end

		mids_hash = nl_ids_to_hash(mids)

		permanently_deleted = 0
		@user.deleted_messages.process do |message|
			if mids_hash[message.id]
				message.delete

				permanently_deleted += 1
			end
		end

		gone = 0
		@user.sent_messages.process do |message|
			if mids_hash[message.id]
				message.delete
				gone += 1
			end
		end

		moved_to_trash = 0
		@user.received_messages.process do |message|
			if mids_hash[message.id]
				message.delete
				moved_to_trash += 1
			end
		end
		
		render :json => {
			:ok => true, :mids => mids, 
			:permanently_deleted => permanently_deleted,
			:moved_to_trash => moved_to_trash,
			:gone => gone
		}
	end

	# GET /user/send_message
	# params[:to] -- json array of ids
	# params[:subject]
	# params[:body]
	# returns json
	def send_message
		to = params[:to]
		subject = params[:subject]
		body = params[:body]

		@user = current_user()

		error = []
		if !subject || subject.blank?
			error << "Subject is invalid"
		end

		if !body || body.blank?
			error << "Body is invalid"
		end

		# Allow HTML but remove all script tags
		body.gsub! /\<\s*script.+\<\s*\/\s*script\s*\>/m, ""
		body.gsub! /\<\s*script.+/m, ""

		to.each do |id|
			if !id || id !~ /^\d+$/
				error << "To field is invalid"
				break
			end
		end

		if error.size > 0
			render :json => {:okay => false, :error => error}
			return
		end

		message_rows = []
		client = Faye::Client.new(get_faye_url)
		to.each do |id|
			user = User.find_by_id(id)
			next unless user
			message = @user.send_message(user, {:topic => subject, :body => body})

			message_row = render_to_string :partial => 'inbox_message', :layout => false, :locals => {:m => message}

			client.publish("/messages/#{user.id}", {:message_row => message_row});
			message_rows << message_row


			Thread.new do
				unless user.getProp("inbox_block_emails")
					UsersMailer.message_mail(@user, user, subject, body, message.id).deliver
				end
				ActiveRecord::Base.connection.close
			end
		end

		render :json => {:ok => true, :message_rows => message_rows}
	end

	# GET /users/inbox
	# Yes, I agree this should all be refactored into a
	# a separate Inbox controller but Meh
	def inbox
		view = params[:v]
		mid = params[:mid]

		@user = current_user
		@received = @user.received_messages
		@readed = @user.received_messages.readed
		@unreaded = @user.received_messages.unreaded
		@deleted = @user.deleted_messages.are_to(@user)
		@sent = @user.sent_messages

		@select_messages = nil
		case view
		when "received"
			@select_messages = @received
			@view = :received #inbox
		when "read"
			@select_messages = @readed
			@view = :read
		when "unread"
			@select_messages = @unreaded
			@view = :unread
		when "sent"
			@select_messages = @sent
			@view = :sent
		when "trash"
			@select_messages = @deleted
			@view = :trash
		else
			@select_messages = @received
			@view = :unread
		end

		get_faye_url

		if mid && !mid.blank?
			@message = @select_messages.with_id(mid).all
		else
			@message = nil
		end

		@message = @message[0] if @message && @message.length > 0

		@block_emails = @user.getProp("inbox_block_emails")
	end

	# GET /user/set_prop
	# params[:name] = name of property
	# params[:value] = value of property
	def set_prop
		@user = current_user()
		name = params[:name]
		value = params[:value]

		unless UserProperty.valid_properties.include?(name)
			render :json => {:ok => false, :error => "#{name} is not a valid property", :name => name, :value => value}
			return
		end
		if !value || value.blank?
			value = nil
		end
		value = nil if value == "false"
		value = true if value == "true"


		@user.setProp(name, value)
		render :json => {:ok => true, :name => name, :value => value}
	end

	# GET /users/:id
	def show # show current user home page
		logger.info "**USER SHOW**"
		@user = nil
		q = params[:id]

		if q
			if q.include?("@")
				@user = User.find_by_email(q)
			else
				@user = User.find_by_id(q)
			end
		end

		if @user && current_user() != @user
			render :public_profile
			return
		end

		render :show
	end
	
	# GET /user/
	def index
		@users = User.all
	end
	
	# GET /user/invite
	def invite
		
	end
	
	# POST /users/invite_user
	def invite_user
		name	= params[:name]
		email = params[:email]
		
		respond_to do |format|
			if name != nil && !name.blank? && email != nil && !email.blank? && email_valid(email) && User.find_by_email(email) == nil
				logger.info("****Name  = #{name}")
				logger.info("****Email = #{email}")
				#--Create and Save User--
				@tmp_password = Devise.friendly_token[0,6]
				@new_user = User.new(:name => name.titleize, :email => email, :password => @tmp_password, :password_confirmation => @tmp_password)
				logger.info("**NEW USER**\n")
				logger.info(@new_user.to_s)
				
				@new_user.save
				
				#--Email temporary password to @new_user
				UsersMailer.invitation_mail(current_user, @new_user, @tmp_password).deliver
				
				format.html #renders success message
			else
				logger.info("****Invalid Input")
				format.html { redirect_to '/user/invite', :notice => "Invalid Input" }
			end
    end  
      
 
	end
	
	private

	def get_faye_url
		@faye_url = Rails.application.config.action_mailer.default_url_options[:host].clone
		if @faye_url =~ /\:\d+$/
			@faye_url.gsub!(/\:\d+$/, ':9292')
		else
			@faye_url += ":9292"
		end
		@faye_url = "http://#{@faye_url}/faye"
		return @faye_url
	end
	
	def auth
		if !user_signed_in?
			redirect_to '/perm'
		end
	end
	
	def email_valid(email)
		return true if email =~ /^.+\@.+\..+$/
		return false
	end

	def nl_ids_to_hash(mids)
		mids_hash = Hash.new
		mids = mids.split("\n").select{|e| e =~ /^\d+$/}.map{|e| e.to_i}
		mids.each do |id| mids_hash[id] = true end
		return mids_hash
	end
	
end
