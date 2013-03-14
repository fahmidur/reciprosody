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
		owner_text = params[:tool].delete(:owner)
		corpora_text = params[:tool].delete(:corpora)

		@tool = Tool.new(params[:tool])
			
	end

	private

	def corpora_from_text(corpora_text)
		corpora = []
		if corpora_text && !corpora_text.blank?
			corpora_text.split("\n").each do |cid|
				corp = Corpus.find_by_id(cid)
				corpora << corp if corp
			end
		end
		return corpora
	end
	#--------FILTERS--------------------------------------------------------
  	# 
  	#-----------------------------------------------------------------------

  	# Allows only users
	def user_filter
		redirect_to '/perm' unless user_signed_in?
	end
end