class AdminsController < ApplicationController
	before_filter :user_filter
	before_filter :super_filter, :except => [:request_a_key, :process_request_form, :wait]

	# admin panel
	def show

	end

	def index
		@super_users = User.supers
	end

	# /admin/usersearch_logs
	# params[:resourcetype]
	# params[:page]
	def usersearch_logs
		resourceType = ResourceType.find_by_name(params[:resourcetype])
		if resourceType
			@items = SearchLogEntry.where(:resource_type_id => resourceType.id).includes(:resource_type, :user).order('created_at DESC').page(params[:page])
		else
			@items = SearchLogEntry.all.includes(:resource_type, :user).order('created_at DESC').page(params[:page])
		end
	end

	# GET admin/request_a_key
	def request_a_key
		@user = current_user()
	end

	# POST admin/process_request_form
	def process_request_form
		#redirect_to '/admins/request_a_key', :notice => 'Invalid Captcha' unless verify_recaptcha
		unless verify_recaptcha
			redirect_to '/admin/request_a_key', :notice => 'Invalid Captcha'
			return
		end
		user = current_user();

		SuperKeyRequest.destroy_all(:user_id => user.id)
		SuperKeyRequest.create(:user_id => user.id, :token => SecureRandom.uuid);

		redirect_to '/admin/wait'
	end

	# DELETE admins/1
	def destroy
		user = User.find_by_id(params[:id])
		unless user && user.super_key != nil
			redirect_to '/admins', :notice => 'User is not an Admin'
			return
		end
		if user == current_user()
			redirect_to '/admins', :notice => 'Sorry, only another Admin can delete you as an Admin.'
			return
		end
		SuperKey.destroy_all(:user_id => user.id)
		redirect_to '/admins'
	end

	def wait

	end

	private

	# of course only users can access this controller
	def user_filter
		redirect_to '/perm' unless user_signed_in?
	end

	# only superkey holders can access this controller
	def super_filter
		redirect_to '/admin/request_a_key' unless current_user().super_key != nil
	end

end