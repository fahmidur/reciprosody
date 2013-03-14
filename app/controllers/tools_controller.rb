class ToolsController < ApplicationController
	before_filter :user_filter, :except => [:index]


	def index
		@tools = Tool.all
	end

	def new
		@tool = Tool.new
	end

	# POST /tools
	def create
		
	end

	#--------FILTERS--------------------------------------------------------
  	# 
  	#-----------------------------------------------------------------------

  	# Allows only users
	def user_filter
		redirect_to '/perm' unless user_signed_in?
	end
end