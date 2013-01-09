class PublicationsController < ApplicationController
	include UsesUpload

	def index
		#renders view/publications/index.html.erb
		@pubs = Publication.all
	end

	def new
		@publication = Publication.new
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