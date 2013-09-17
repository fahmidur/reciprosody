class GraphicsController < ApplicationController

	#GET /graphics/one
	def one
		@corpora = Corpus.all
		@pubs = Publication.all
		@tools = Tool.all
		@users = User.all

		@user_corp_rel = Membership.all
		@user_pub_rel = PublicationMembership.all
		@user_tool_rel = ToolMembership.all
	end
end