class ToolsController < ApplicationController
	before_filter :user_filter, :except => [:index, :show, :publications, :corpora, :download, :follow]
	before_filter :existence_filter, :only => [
		:show, :edit, :update, :destroy,
		:add_corpus_rel, :update_corpus_rel, :delete_corpus_rel,
		:add_publication_rel, :update_publication_rel, :delete_publication_rel,
		:publications, :corpora,
	]
	before_filter :owner_filter, :only => [
			:edit, :update, :destroy,
			:add_corpus_rel, :update_corpus_rel, :delete_corpous_rel,
			:add_publication_rel, :update_publication_rel, :delete_publication_rel,
		]

	autocomplete :tool, :name, :full => true, :display_value => :ac_small_format, :extra_data => [:id]
	autocomplete :programming_language, :name, :full => false, :limit => 20, :extra_data => [:id]
	autocomplete :tool_keyword, :name, :full => true


	# GET /tools/5/follow
	def follow
		@tool = Tool.find_by_id(params[:id])
		if @tool.url && @tool.url.present?
			@tool.user_action_from(current_user, 
				:follow_link, {
					:visible => false
				},
				method(:action_notify)
			);
			redirect_to @tool.url
		else
			redirect_to "/tool/#{@tool.id}"	
		end
	end

	def add_publication_rel
		@tool = Tool.find_by_id(params[:id])
		name = params[:name]
		name[/<(\d+)>/]
		publication_id = $1.to_i
		@pub = Publication.find_by_id(publication_id)

		relationship = params[:relationship]
		relationship = "uses" if !relationship || relationship.blank?

		if @pub && ToolPublicationRelationship.where(:tool_id => @tool.id, :publication_id => @pub.id)
			ToolPublicationRelationship.create(:tool_id => @tool.id, :publication_id => @pub.id, :name => relationship)
		end
		redirect_to "/tools/#{@tool.id}/publications"
	end

	def delete_publication_rel
		@tool = Tool.find_by_id(params[:id])
		@publicationToolRelationship = ToolPublicationRelationship.find_by_id(params[:rid])
		unless @publicationToolRelationship
			redirect_to '/perm'
			return
		end
		@publicationToolRelationship.destroy
		redirect_to "/tools/#{@tool.id}/publications"
	end

	def update_publication_rel
		@tool = Tool.find_by_id(params[:id])
		@publicationToolRelationship = ToolPublicationRelationship.find_by_id(params[:rid])
		unless @publicationToolRelationship
			redirect_to '/perm'
			return
		end
		relationship = params[:relationship]
		relationship = "uses" if !relationship || relationship.blank?

		@publicationToolRelationship.name = relationship
		@publicationToolRelationship.save

		redirect_to "/tools/#{@tool.id}/publications"
	end

	def add_corpus_rel
		@tool = Tool.find_by_id(params[:id])
		name = params[:name]
		name[/<(\d+)>/]
		corpus_id = $1.to_i
		@corpus = Corpus.find_by_id(corpus_id)

		relationship = params[:relationship]
		relationship = "uses" if !relationship || relationship.blank?

		if @corpus && ToolCorpusRelationship.where(:corpus_id => @corpus.id, :tool_id => @tool.id).empty?
			ToolCorpusRelationship.create(:corpus_id => @corpus.id, :tool_id => @tool.id, :name => relationship)
		end
		redirect_to "/tools/#{@tool.id}/corpora"
	end

	def update_corpus_rel
		@tool = Tool.find_by_id(params[:id])
		@toolCorpusRelationship = ToolCorpusRelationship.find_by_id(params[:rid])
		unless @toolCorpusRelationship
			redirect_to '/perm'
			return
		end

		relationship = params[:relationship]
		relationship = "uses" if !relationship || relationship.blank?

		@toolCorpusRelationship.name = relationship
		@toolCorpusRelationship.save

		redirect_to "/tools/#{@tool.id}/corpora"
	end

	def delete_corpus_rel
		@tool = Tool.find_by_id(params[:id])
		@toolCorpusRelationship = ToolCorpusRelationship.find_by_id(params[:rid])
		unless @toolCorpusRelationship
			redirect_to '/perm'
			return
		end
		@toolCorpusRelationship.destroy
		redirect_to "/tools/#{@tool.id}/corpora"
	end

	# paginated
	# params[:page]
	# params[:order]
	# params[:query]
	# params[:roles]
	#
	def index
		page = params[:page]
		query = params[:query]
		order = params[:order] || :created_at

		valid_orders = Tool.valid_orders
		unless valid_orders.include?(order)
			order = :created_at
		end
		roles = params[:roles]
		if(roles && roles.length > 0)
			roles = roles.split(",") 
			uniqRoles = {}
			roles.each { |r| uniqRoles[r] = true }
			idArray = []
			uniqRoles.each do |name,v|
				case name
				when "owner"
					idArray += current_user.tool_owner_of
				when "member"
					idArray += current_user.tool_member_of
				when "approver"
					idArray += current_user.tool_approver_of
				end
			end
			idArray.map! {|e| e.id }
			@tools = Tool.where(:id => idArray).order(order)
		else
			@tools = Tool.order(order)
		end

		if valid_orders[0..1].include?(order)
			@tools = @tools.reverse_order
		end

		# qs = "%#{query}%"
		# @tools = @tools.where("name LIKE ? OR description LIKE ? OR authors LIKE ?", qs, qs, qs).page(page)
		# @tools = @tools.page(page)

		if query && query.present?
			@tools = Kaminari.paginate_array(@tools.wsearch(query)).page(page)
			SearchLogEntry.make(current_user(), :tool, query, @tools.map{|e| e.id }.inspect)
		else
			@tools = @tools.page(page)
		end
	end

	def corpora
		@tool = Tool.find_by_id(params[:id])
		@toolCorpusRelationships = ToolCorpusRelationship.where(:tool_id => @tool.id)
	end

	def publications
		@tool = Tool.find_by_id(params[:id])
		@publicationToolRelationships = ToolPublicationRelationship.where(:tool_id => @tool.id).includes(:publication)
	end

	def manage_members
		@tool = Tool.find_by_id(params[:id])
		@memberships = @tool.tool_memberships.includes(:user)

		#-Both Formats are Used
		respond_to do |format|
		  format.html
		  format.json { render json: [@memberships] }
		end
	end

	def add_member
		@tool = Tool.find_by_id(params[:id])
		errors = []
		
		memHash = params[:member]
		if errors.length == 0 && !memHash
			errors.push("Invalid parameter format")
		end

		role = nil
		role = memHash[:role] if errors.length == 0
		
		if errors.length == 0 && ( !role || role.blank? || !(ToolMembership.roles.include?(role)) )
			errors.push("Invalid role")
		end
		
		memberEmail = nil
		if errors.length == 0 && memHash[:email] =~ /<(.+)>/
			memberEmail = $1
		end
		
		if errors.length == 0 && memberEmail == nil
			errors.push("Invalid member format #{memHash[:email]}");
		end
		
		@member = User.find_by_email(memberEmail)
		if errors.length == 0 && @member == nil
			errors.push("User does not exist")
		end
		
		
		membership = ToolMembership.where(:tool_id => @tool.id, :user_id => @member.id).first if errors.length == 0
		
		if errors.length == 0 && membership != nil
			errors.push("Membership already exists")
		end
		
		
		if errors.length == 0
			membership = ToolMembership.create(:user_id => @member.id, :tool_id => @tool.id, :role => role)
		end
			
		respond_to do |format|
			format.html { redirect_to manage_members_tool_path(@tool)}
			
			format.json do
				if(errors.length == 0)
					render :json => {:ok => true, :resp => render_to_string(:partial => 'member', :layout => false, :locals => {:mem => membership}, :formats => [:html]) }
				else
					render :json => {:ok => false, :resp => "#{errors.join("\n")}"}
				end
			end
			
		end
	end

	def remove_member
		membership = ToolMembership.find_by_id(params[:mem_id])

		respond_to do |format|
			format.json do 
				if membership
					id = membership.id
					membership.destroy
					render :json => {:ok => true, :id => id  } 
				else
					render :json => {:ok => false, :id => params[:mem_id] }
				end
			end
		end
	end

	def update_member
		membership = ToolMembership.find_by_id(params[:mem_id])
		role = params[:role]
		
		respond_to do |format|
			format.json do
				if membership && ToolMembership.roles.include?(role)
					membership.role = role
					membership.save
					render :json => {:ok => true, :id => membership.id }	
				else
					render :json => {:ok => false, :id => membership.id, :role => membership.role}
				end
			end
		end
	end



	def destroy
		@tool = Tool.find_by_id(params[:id])
		@tool.destroy
		redirect_to '/tools'
	end

	def show
		@tool = Tool.find_by_id(params[:id])
	end

	def new
		@tool = Tool.new
		@corpus = Corpus.find_by_id(params[:corpus_id]) if params[:corpus_id]
		session[:resumable_filename] = nil
	end

	def edit
		@tool = Tool.find_by_id(params[:id])
		session[:resumable_filename] = nil
	end

	def update
		@tool = Tool.find_by_id(params[:id])
		owner_text = params[:tool].delete(:owner)
		corpora_text = params[:tool].delete(:corpora)
		publications_text = params[:tool].delete(:publications)

		if !owner_text || owner_text.blank?
			@tool.errors[:owner] = " must be specified"
		end

		owner_email = ""
		if owner_text =~ /\<(.+)\>/
			owner_email = $1
		end
		@owner = User.find_by_email(owner_email);
		if !@owner
			@tool.errors[:owner] = " does not exist."
		end

		@corpora = corpora_from_text(corpora_text)
		@publications = publications_from_text(publications_text)

		respond_to do |format|
			if @tool.errors.none? && @tool.update_attributes(params[:tool]) && create_tool
				ToolMembership.where(:user_id => current_user().id, :tool_id => @tool.id).destroy_all

				# You cannot actually set someone other than yourself as the owner
				ToolMembership.create(
					:tool_id		=> @tool.id, 
					:user_id		=> current_user().id,
					:role			=> 'owner')

				format.html {redirect_to @tool}
				format.json do
					render :json => {:ok => true, :res => @tool.id}
				end
			else
				format.json do 
					render :json => {:ok => false, :errors => @tool.errors.to_a }
				end
			end
		end

	end

	# POST /tools
	def create
		owner_text = params[:tool].delete(:owner)
		corpora_text = params[:tool].delete(:corpora)
		publications_text = params[:tool].delete(:publications)

		@tool = Tool.new(params[:tool])

		if !owner_text || owner_text.blank?
			@tool.errors[:owner] = " must be specified"
		end

		owner_email = ""
		if owner_text =~ /\<(.+)\>/
			owner_email = $1
		end
		@owner = User.find_by_email(owner_email);
		if !@owner
			@tool.errors[:owner] = " does not exist."  	
		end

		@corpora = corpora_from_text(corpora_text)

		respond_to do |format|
			if @tool.errors.none? && @tool.save && create_tool

				ToolMembership.create(
					:tool_id		=> @tool.id, 
					:user_id		=> current_user().id,
					:role			=> 'owner')

				format.html {redirect_to @tool}
				format.json do
					render :json => {:ok => true, :res => @tool.id}
				end
			else
				format.json do 
					render :json => {:ok => false, :errors => @tool.errors.to_a}
				end
			end
		end
	end

	def download
		@tool = Tool.find_by_id(params[:id])
		unless @tool
			redirect_to '/perm'
			return
		end
		local = @tool.local
		unless local
			redirect_to '/perm'
		end
		action = @tool.user_action_from(current_user, 
			:download,
			{},
			method(:action_notify)
		)
		
		send_file local
	end

	private

	def create_tool
		if @corpora
			ToolCorpusRelationship.where(:tool_id => @tool.id).destroy_all
			@corpora.each do |corp|
				ToolCorpusRelationship.create(
					:tool_id => @tool.id,
					:corpus_id		=> corp.id,
					:name 			=> "for");
			end
		end
		if @publications
			ToolPublicationRelationship.where(:tool_id => @tool.id).destroy_all
			@publications.each do |pub|
				ToolPublicationRelationship.create(
					:tool_id => @tool.id,
					:publication_id => pub.id,
					:name => 'associated'
				);
			end
		end
		@tool.keywords_array.each do |kw|
			ToolKeyword.create(:name => kw) unless ToolKeyword.find_by_name(kw)
		end

		rfname = session[:resumable_filename]
		@file = rfname ? File.new(rfname) : nil
		return true unless @file

		Dir.chdir Rails.root
		path = "tools/#{@tool.id}"

		FileUtils.mkdir_p path
		FileUtils.rm_f "#{path}/*"

		extname = File.extname(@file.path)
		#name = @tool.name.underscore
		name = session[:resumable_original_filename]

		path += "/#{name}"
		File.open(path, "wb") {|f| f.write(@file.read)}

		@tool.local = path
		@tool.save

		return true
	end

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

	def publications_from_text(text)
		publications = []
		if text && !text.blank?
			text.split("\n").each do |id|
				pub = Publication.find_by_id(id)
				publications << pub if pub
			end
		end
		return publications
	end
	#--------FILTERS--------------------------------------------------------
  	# 
  	#-----------------------------------------------------------------------

  	# Allows only users
	def user_filter
		redirect_to '/perm' unless user_signed_in?
	end

	# Blocks if Corpus does not exist
	def existence_filter
		@tool = Tool.find_by_id(params[:id])
		redirect_to '/perm' unless @tool
	end

	# Allows only owners
  	# Is applied in combination with user_filter
	def owner_filter
		@tool = Tool.find_by_id(params[:id])

		#Dont filter super_key holders
		return if current_user().super_key != nil

		redirect_to '/perm' unless @tool && @tool.owners.include?(current_user())
	end

end