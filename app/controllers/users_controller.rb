class UsersController < ApplicationController
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
		render :json => User.where("name LIKE ? OR email LIKE ?", q, q)
	end

	# GET /users/inbox
	def inbox
		view = params[:v]
		mid = params[:mid]

		@user = current_user
		@received = @user.received_messages
		@deleted = @user.deleted_messages
		@sent = @user.sent_messages

		@select_messages = nil
		case view
		when "received"
			@select_messages = @received
			@view = :received
		when "sent"
			@select_messages = @user.sent_messages
			@view = :sent
		when "trash"
			@select_messages = @deleted
			@view = :trash
		else
			@select_messages = @received
			@view = :received
		end

		if mid && !mid.blank?
			@message = @select_messages.with_id(mid).all
		else
			@message = nil
		end

		@message = @message[0] if @message && @message.length > 0
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
	
	def auth
		if !user_signed_in?
			redirect_to '/perm'
		end
	end
	
	def email_valid(email)
		return true if email =~ /^.+\@.+\..+$/
		return false
	end
	
end
