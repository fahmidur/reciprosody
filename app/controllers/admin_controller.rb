class AdminController < ApplicationController
	before_filter :magic_filter

	# GET 
	def index
	end

	private

	# access based on magic token
	def magic_filter
		
	end

end