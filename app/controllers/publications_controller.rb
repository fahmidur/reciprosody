class PublicationsController < ApplicationController
	before_filter :user_filter, :except => [:index, :show, :download]
	before_filter :owner_filter, 
		:only => [:edit, :update, :destroy,
				  :add_corpus_rel, :update_corpus_rel, :delete_corpus_rel,
				  :manage_members, :add_member, :update_member,:remove_member]


	autocomplete :publication_keyword, :name, :full => true
	autocomplete :publication, :name, :full => true, :display_value => :ac_small_format, :extra_data => [:id]

	# GET /publications/5/add_tool_rel
	def add_tool_rel
		logger.info("********************************GOT HERE******************")
		@pub = Publication.find_by_id(params[:id])
		name = params[:name]
		name[/<(\d+)>/]
		tool_id = $1.to_i
		@tool = Tool.find_by_id(tool_id)

		#relationship to tool
		relationship = params[:relationship]
		relationship = "uses" if !relationship || relationship.blank?

		if @tool && ToolPublicationRelationship.where(:publication_id => @pub.id, :tool_id => @tool.id).empty?
			logger.info("********************************GOT HERE******MAKING RELATIONSHIP************")
			ToolPublicationRelationship.create(:publication_id => @pub.id, :tool_id => @tool.id, :name => relationship)
		end

		redirect_to "/publications/#{@pub.id}/tools"
	end

	def update_tool_rel
		@pub = Publication.find_by_id(params[:id])
		@publicationToolRelationship = ToolPublicationRelationship.find_by_id(params[:rid])
		unless @publicationToolRelationship
			redirect_to '/perm'
			return
		end

		relationship = params[:relationship]
		relationship = "uses" if !relationship || relationship.blank?

		@publicationToolRelationship.name = relationship
		@publicationToolRelationship.save

		redirect_to "/publications/#{@pub.id}/tools"
	end

	def delete_tool_rel
		@pub = Publication.find_by_id(params[:id])
		# forget the check if pub exists, make existence_filter later
		@publicationToolRelationship = ToolPublicationRelationship.find_by_id(params[:rid])
		unless @publicationToolRelationship
			redirect_to '/perm'
			return
		end

		@publicationToolRelationship.destroy
		redirect_to "/publications/#{@pub.id}/tools"
	end

	# GET /publication/5/add_corpus_rel
	# params[:name] = AutoBI<38>
	# params[:relationship] = for
	# params[:id] = <the id of the publication>
	def add_corpus_rel
		@pub = Publication.find_by_id(params[:id])
		name = params[:name]
		name[/<(\d+)>/]
		corpus_id = $1.to_i
		@corpus = Corpus.find_by_id(corpus_id)

		relationship = params[:relationship]
		relationship = "uses" if !relationship || relationship.blank?

		if @corpus && PublicationCorpusRelationship.where(:corpus_id => @corpus.id, :publication_id => @pub.id).empty?
			PublicationCorpusRelationship.create(:corpus_id => @corpus.id, :publication_id => @pub.id, :name => relationship)
		end

		redirect_to "/publications/#{@pub.id}/corpora"
	end


	def update_corpus_rel
		@pub = Publication.find_by_id(params[:id])
		@publicationCorpusRelationship = PublicationCorpusRelationship.find_by_id(params[:rid])
		unless @publicationCorpusRelationship
			redirect_to '/perm'
			return
		end
		relationship = params[:relationship]
		relationship = "uses" if !relationship || relationship.blank?

		@publicationCorpusRelationship.name = relationship
		@publicationCorpusRelationship.save

		redirect_to "/publications/#{@pub.id}/corpora"
	end

	def delete_corpus_rel
		@pub = Publication.find_by_id(params[:id])
		unless @pub
			redirect_to '/perm'
			return
		end
		
		@publicationCorpusRelationship = PublicationCorpusRelationship.find_by_id(params[:rid])
		unless @publicationCorpusRelationship
			redirect_to '/perm'
			return
		end
		@publicationCorpusRelationship.destroy
		redirect_to "/publications/#{@pub.id}/corpora"
	end

	def index
		#renders view/publications/index.html.erb
		@pubs = Publication.all
	end

	# GET /publications/new
	# params[:corpus_id]
	def new
		@pub = Publication.new
		@corpus = Corpus.find_by_id(params[:corpus_id]) if params[:corpus_id]
		session[:resumable_filename] = nil
	end

	def create
		owner_text = params[:publication].delete(:owner)
		corpora_text = params[:publication].delete(:corpora)
		tools_text = params[:publication].delete(:tools)


		params[:publication][:pubdate] = DateTime.new(params[:publication][:pubdate].to_i)

		@pub = Publication.new(params[:publication])
		if !owner_text || owner_text.blank?
			@pub.errors[:owner] = " must be specified"
		end

		owner_email = ""
		if owner_text =~ /\<(.+)\>/
			owner_email = $1
		end
		@owner = User.find_by_email(owner_email);
		if !@owner
			@pub.errors[:owner] = " does not exist."  	
		end

		@corpora = corpora_from_text(corpora_text)
		@tools = tools_from_text(tools_text)

		respond_to do |format|
			if @pub.errors.none? && @pub.save && create_publication

				# User now "owns" this publication
				PublicationMembership.create(
					:publication_id	=> @pub.id, 
					:user_id		=> @owner.id,
					:role			=> 'owner')

				format.html {redirect_to @pub}
				format.json do
					render :json => {:ok => true, :res => @pub.id}
				end
			else
				format.json do 
					render :json => {:ok => false, :errors => @pub.errors.to_a}
				end
			end
		end
	end
	
	def update
		@pub = Publication.find_by_id(params[:id])

		owner_text = params[:publication].delete(:owner)
		corpora_text = params[:publication].delete(:corpora)
		tools_text = params[:publication].delete(:tools)

		if !owner_text || owner_text.blank?
			@pub.errors[:owner] = " must be specified"
		end
		owner_email = ""
		if owner_text =~ /\<(.+)\>/
			owner_email = $1
		end
		@owner = User.find_by_email(owner_email);
		if !@owner
			@pub.errors[:owner] = " does not exist."
		end

		@corpora = corpora_from_text(corpora_text)
		@tools = tools_from_text(tools_text)

		params[:publication][:pubdate] = DateTime.new(params[:publication][:pubdate].to_i)

		respond_to do |format|
			if @pub && @pub.update_attributes(params[:publication]) && create_publication()
				PublicationMembership.where(:user_id => current_user().id, :publication_id => @pub.id).destroy_all
				
				# You cannot actually set someone other than yourself as the owner
				PublicationMembership.create(
					:publication_id	=> @pub.id,
					:user_id		=> current_user().id,
					:role			=> 'owner')

				format.html { redirect_to @pub}
				format.json do
					render :json => {:ok => true, :res => @pub.id}
				end
			else
				format.html { render :action => 'edit'}
				format.json do
					render :json => {:ok => false, :errors => @pub.errors.to_a}
				end
			end
		end
	end

	def create_publication
		if @tools
			ToolPublicationRelationship.where(:publication_id => @pub.id).destroy_all
			@tools.each do |tool|
				ToolPublicationRelationship.create(
					:publication_id => @pub.id,
					:tool_id => tool.id,
					:name => "uses"
				);
			end
		end
		if @corpora
			PublicationCorpusRelationship.where(:publication_id => @pub.id).destroy_all
			@corpora.each do |corp|
				PublicationCorpusRelationship.create(
					:publication_id => @pub.id,
					:corpus_id		=> corp.id,
					:name 			=> "uses");
			end
		end
		
		@pub.keywords_array.each do |kw|
			PublicationKeyword.create(:name => kw) unless PublicationKeyword.find_by_name(kw)
		end

		#@file = get_upload_file
		rfname = session[:resumable_filename]
		@file = rfname ? File.new(rfname) : nil

		return true unless @file

		Dir.chdir Rails.root
		path = "publications/#{@pub.id}"

		`mkdir -p #{path}`
		`rm #{path}/*`
		
		# TO-Do: Possible Race Condition occuring above
		# Fix with a blocking call to mkdir and rm
		extname = File.extname(@file.path)
		#name = @pub.name.underscore
		name = session[:resumable_original_filename]

		path += "/#{name}#{extname}"
		File.open(path, "wb") {|f| f.write(@file.read)}

		@pub.local = path
		@pub.save

		return true
	end

	def edit
		@pub = Publication.find_by_id(params[:id])
		@corpora = @pub.corpora
		session[:resumable_filename] = nil
	end

	def manage_members
		@pub = Publication.find_by_id(params[:id])
		@memberships = @pub.publication_memberships.includes(:user)

		#-Both Formats are Used
		respond_to do |format|
		  format.html
		  format.json { render json: [@memberships] }
		end
	end


	def add_member
		@pub = Publication.find_by_id(params[:id])
		errors = []
		
		memHash = params[:member]
		if errors.length == 0 && !memHash
			errors.push("Invalid parameter format")
		end

		role = nil
		role = memHash[:role] if errors.length == 0
		
		if errors.length == 0 && ( !role || role.blank? || !(PublicationMembership.roles.include?(role)) )
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
		
		
		membership = PublicationMembership.where(:publication_id => @pub.id, :user_id => @member.id).first if errors.length == 0
		
		if errors.length == 0 && membership != nil
			errors.push("Membership already exists")
		end
		
		
		if errors.length == 0
			membership = PublicationMembership.create(:user_id => @member.id, :publication_id => @pub.id, :role => role)
		end
			
		respond_to do |format|
			format.html { redirect_to manage_members_publication_path(@pub)}
			
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
		membership = PublicationMembership.find_by_id(params[:mem_id])

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
		membership = PublicationMembership.find_by_id(params[:mem_id])
		role = params[:role]
		
		respond_to do |format|
			format.json do
				if membership && PublicationMembership.roles.include?(role)
					membership.role = role
					membership.save
					render :json => {:ok => true, :id => membership.id }	
				else
					render :json => {:ok => false, :id => membership.id, :role => membership.role}
				end
			end
		end
	end


	# DELETE /publications/1
	#
	def destroy
		@pub = Publication.find_by_id(params[:id])

		respond_to do |format|
			if @pub

				@pub.destroy

				format.html { redirect_to publications_url }
				format.json { render :json => {:ok => true } }
			else
				format.html { redirect_to publications_url }
				format.json { render :json => {:ok => false } }
			end
		end
	end

	def download
		@pub = Publication.find_by_id(params[:id])
		unless @pub
			redirect_to '/perm'
			return
		end
		local = @pub.local
		unless local
			redirect_to '/perm'
		end
		send_file local
	end

	# GET /publications/1
	def show
		@pub = Publication.find_by_id(params[:id])
		unless @pub
			redirect_to '/perm'
			return
		end
	end

	def corpora
		@pub = Publication.find_by_id(params[:id])
		unless @pub
			redirect_to '/perm'
			return
		end
		@publicationCorpusRelationships = PublicationCorpusRelationship.where(:publication_id => @pub.id).includes(:corpus)
	end

	def tools
		@pub = Publication.find_by_id(params[:id])
		
		unless @pub
			redirect_to '/perm'
			return
		end

		# To-Do: Rename ToolPublicationRelationship model to PublicationToolRelationship
		# because it is a relationship from Tools to Publications

		@publicationToolRelationships = ToolPublicationRelationship.where(:publication_id => @pub.id).includes(:tool)
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

	def tools_from_text(text)
		tools = []
		if text && !text.blank?
			text.split("\n").each do |id|
				tool = Tool.find_by_id(id)
				tools << tool if tool
			end
		end
		return tools
	end

	#--------FILTERS--------------------------------------------------------
  	# 
  	#-----------------------------------------------------------------------

  	# Allows only users
	def user_filter
		redirect_to '/perm' unless user_signed_in?
	end
  
  	# Allows only owners
  	# Is applied in combination with user_filter
	def owner_filter
		@pub = Publication.find_by_id(params[:id])

		#Dont filter super_key holders
		return if current_user().super_key != nil

		redirect_to '/perm' unless @pub && @pub.owners.include?(current_user())
	end

end