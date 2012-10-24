class UsersController < ApplicationController
	protect_from_forgery
	before_filter :auth
	
	def show # show current user home page
		
	end
	
	def index
		@users = User.all
	end
	
	private
	
	def auth
		if !user_signed_in?
			redirect_to '/perm'
		end
	end
	
end
