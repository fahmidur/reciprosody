class PublicationsController < ApplicationController
	include UsesUpload

	def index
		#renders view/publications/index.html.erb
		@pubs = Publication.all
	end

	# GET /publications/new
	# params[:corpus_id]
	def new
		@publication = Publication.new
		@corpus = Corpus.find_by_id(params[:corpus_id]) if params[:corpus_id]
	end

	def create
		owner_text = params[:publication].delete(:owner)
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

		respond_to do |format|
			if @pub.errors.none? && create_publication() && @pub.save
				PublicationMembership.create(
					:publication_id	=> @pub.id, 
					:user_id		=> @owner.id,
					:role			=> 'owner')
				format.html {redirect_to @pub}
			else

			end
		end
	end

	def create_publication
		@file = get_upload_file
		return true unless @file

		Dir.chdir Rails.root
		path = "publications/#{@pub.id}"

		`mkdir -p #{path}`
		`rm #{path}/*`
		
		path += "/#{File.basename(@file.path)}"

		File.open(path, "wb") {|f| f.write(@file.read)}

		@pub.local = path
		return true
	end

	def edit
		@pub = Publication.find_by_id(params[:id])
	end

	def update
		@pub = Publication.find_by_id(params[:id])

		respond_to do |format|
			if @pub && create_publication() && @pub.update_attributes(params[:publication])

				format.html { redirect_to @pub}
			else
				format.html { render :action => 'edit'}
			end
		end
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
		@keywords = @pub.keywords.to_s.split(/[^\w,\-]+/)
	end

end