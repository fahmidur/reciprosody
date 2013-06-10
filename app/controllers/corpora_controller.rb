class CorporaController < ApplicationController	
	require 'fileutils'
	
	before_filter :user_filter, :except => [:index, :show, :tools, :publications, :comments]
	before_filter :existence_filter, :only => 
		[:show, :publications,
		 :delete_publication_rel, :add_publication_rel, :update_publication_rel,
		 :delete_tool_rel, :add_tool_rel, :update_tool_rel,
		 :manage_members, :add_member, :update_member, :remove_member,
		 :comments, :add_comment, :remove_comment, :refresh_comments,
		 :view_history, :edit, :download, :browse, 
		 :single_download, :single_upload, :single_delete, :single_rename,
		 :update, :destroy]

	before_filter :owner_filter, 
		:only => [:edit, :update, :destroy, 
				  :manage_members, :view_history,
				  :add_member, :update_member,:remove_member,
				  :delete_tool_rel, :add_tool_rel, :update_tool,
				  :delete_publication_rel, :add_publication_rel, :update_publication_rel,
				  :single_upload, :single_delete, :single_rename]

	before_filter :assoc_filter,
		:only => [:add_comment, :remove_comment, :refresh_comments]
				  
	
	autocomplete :language, :name
	autocomplete :license, :name
	autocomplete :user, :name, :full => true, :display_value => :email_format, :extra_data => [:email]

	autocomplete :corpus, :name, :full => true, :display_value => :ac_small_format, :extra_data => [:id, :duration]
	autocomplete :tool_corpus_relationship, :name, :full => true
	autocomplete :publication_corpus_relationship, :name, :full => true
	
	# GET /corpora
	# GET /corpora.json
	#
	# FILTERED_BY: nothing
	#
	def index
		@corpora = Corpus.all

		respond_to do |format|
			format.html # index.html.erb
			format.json { render json: @corpora }
		end
	end

	# GET /corpora/1
	# GET /corpora/1.json
	def show
		@corpus = Corpus.find_by_id(params[:id])
		view_helper = help
		@last_modified = @corpus.svn_last_changed_date
		@revisions = @corpus.svn_revisions

		@archives = []

		archives_hash = Hash.new

		@revisions.downto(1) do |r|
			archives_hash[r] = ["V.#{r} [#{view_helper.time_ago_in_words(@corpus.svn_last_changed_date(r))}]", "+#{r}"]
		end

		Dir.chdir Rails.root

		@archive_names = Dir.entries(@corpus.archives_path).select {|n| n != ".." && n != "." }

		#--Sort from highest to lowest Version
		# @archive_names.sort! do |a, b|
		# 	logger.info("a=#{a} b=#{b}")
		# 	x = a.gsub(/\.#{get_archive_ext(a)}$/, '')[/\d+$/].to_i
		# 	y = b.gsub(/\.#{get_archive_ext(b)}$/, '')[/\d+$/].to_i
		# 	y <=> x
		# end
		
		archive_path = ""
		time = nil
		
		@archive_names.each do |n|
			archive_path = "#{@corpus.archives_path}/#{n}"
			time = view_helper.time_ago_in_words(File.new(archive_path).mtime)
			item = ["V." + n[/(\d+)(?=\.(zip|tgz|tar\.gz|)$)/] + " [#{time}]", n]
			archives_hash[$1.to_i] = item
		end

		archives_hash.each do |k, v|
			@archives << v;
		end

		@archives.sort! do |a, b|
			x = a[0][/\d+/].to_i
			y = b[0][/\d+/].to_i
			y <=> x 
		end

		respond_to do |format|
	  		format.html # show.html.erb
	  		format.json { render json: @corpus }
	
		end
	end
	
	# GET /corpora/1/publications
	# See all publications using this Corpus
	def publications
		@corpus = Corpus.find_by_id(params[:id])
		@publicationCorpusRelationships = PublicationCorpusRelationship.where(:corpus_id => @corpus.id).includes(:publication)
	end

	# DELETE /corpora/:id/delete_publication_rel
	# rid
	def delete_publication_rel
		@corpus = Corpus.find_by_id(params[:id])
		
		@publicationCorpusRelationship = PublicationCorpusRelationship.find_by_id(params[:rid])
		unless @publicationCorpusRelationship
			redirect_to '/perm'
			return
		end
		@publicationCorpusRelationship.destroy
		redirect_to "/corpora/#{@corpus.id}/publications"
	end

	def add_publication_rel
		@corpus = Corpus.find_by_id(params[:id])
		
		name = params[:name]
		name[/<(\d+)>/]

		pub_id = $1.to_i
		@pub = Publication.find_by_id(pub_id)

		relationship = params[:relationship]
		relationship = "uses" if !relationship || relationship.blank?

		if @pub && PublicationCorpusRelationship.where(:corpus_id => @corpus.id, :publication_id => @pub.id).empty?
			PublicationCorpusRelationship.create(:corpus_id => @corpus.id, :publication_id => @pub.id, :name => relationship)
		end

		redirect_to "/corpora/#{@corpus.id}/publications"
	end

	def update_publication_rel
		@corpus = Corpus.find_by_id(params[:id])
		
		@publicationCorpusRelationship = PublicationCorpusRelationship.find_by_id(params[:rid])
		unless @publicationCorpusRelationship
			redirect_to '/perm'
			return
		end
		relationship = params[:relationship]
		relationship = "uses" if !relationship || relationship.blank?

		@publicationCorpusRelationship.name = relationship
		@publicationCorpusRelationship.save

		redirect_to "/corpora/#{@corpus.id}/publications"
	end

	# GET /corpora/1/tools
	# See all Tools using this Corpus
	def tools
		@corpus = Corpus.find_by_id(params[:id])
		@toolCorpusRelationships = ToolCorpusRelationship.where(:corpus_id => @corpus.id).includes(:tool)
	end

	# DELETE /corpora/:id/delete_tool_rel
	# rid
	def delete_tool_rel
		@corpus = Corpus.find_by_id(params[:id])
		
		@toolCorpusRelationship = ToolCorpusRelationship.find_by_id(params[:rid])
		unless @toolCorpusRelationship
			redirect_to '/perm'
			return
		end
		@toolCorpusRelationship.destroy
		redirect_to "/corpora/#{@corpus.id}/tools"
	end

	# GET /corpora/:id/add_tool_rel
	# name: AutoBI<38>
	# relationship: for
	def add_tool_rel
		@corpus = Corpus.find_by_id(params[:id])
		
		name = params[:name]
		name[/<(\d+)>/]

		tool_id = $1.to_i
		@tool = Tool.find_by_id(tool_id)

		relationship = params[:relationship]
		relationship = "for" if !relationship || relationship.blank?

		if @tool && ToolCorpusRelationship.where(:corpus_id => @corpus.id, :tool_id => @tool.id).empty?
			ToolCorpusRelationship.create(:corpus_id => @corpus.id, :tool_id => @tool.id, :name => relationship)
		end

		redirect_to "/corpora/#{@corpus.id}/tools"
	end

	# GET /corpora/:id/update_tool_rel
	# rid
	# relationship: for
	def update_tool_rel
		@corpus = Corpus.find_by_id(params[:id])
		
		@toolCorpusRelationship = ToolCorpusRelationship.find_by_id(params[:rid])
		unless @toolCorpusRelationship
			redirect_to '/perm'
			return
		end
		relationship = params[:relationship]
		relationship = "for" if !relationship || relationship.blank?

		@toolCorpusRelationship.name = relationship
		@toolCorpusRelationship.save

		redirect_to "/corpora/#{@corpus.id}/tools"
	end

	# GET /corpora/1/manage_members
	#
	# FILTERED_BY: owner_filter
	# ACTS_AS: get_members
	#
	def manage_members
		@corpus = Corpus.find_by_id(params[:id])

		@memberships = @corpus.memberships.includes(:user)

		#-Both Formats are Used
		respond_to do |format|
		  format.html
		  format.json { render json: [@memberships] }
		end
	end

	# GET /corpora/1/comments
	# Just the comments page
	def comments
		@corpus = Corpus.find_by_id(params[:id])
		@comments = @corpus.comments
	end

	# GET /corpora/1/add_comment
	# params[:msg] = comment
	# FILTERED_BY: assoc_filter
	#
	def add_comment
		@corpus = Corpus.find_by_id(params[:id])

		msg = params[:msg]
		user = current_user()
		
		respond_to do |format|	

			format.json do
				if @corpus && msg && !msg.blank? && user
					comment = Comment.build_from(@corpus, user.id, msg)
					comment.save
					render :json => {
						:ok => true, 
						:resp => render_to_string(
							:partial => 'comment', 
							:locals => {:comment => comment}, 
							:formats => [:html])
						}
				
				else
					render :json => {:ok => false}
				end
			end

		end
	end
	
	# GET /corpora/1/remove_comment
	# FILTERED_BY assoc_filter
	# Internally allows only comment owners
	#
	# comment_id = params[:comment_id]
	#
	def remove_comment
		@corpus = Corpus.find_by_id(params[:id])
		user = current_user();
		comment_id = params[:comment_id]
		comment = Comment.find_by_id(comment_id)

		respond_to do |format|
			format.html do
				if comment && comment.user_id == user.id
					comment.destroy
					render :text => comment_id
				else
					render :text => "ERROR"
				end
			end
			format.json do
				if comment && comment.user_id == user.id
					comment.destroy
					render :json => {:ok => true}
				else
					render :json => {:ok => false}
				end
			end
		end

	end

	# GET /corpora/1/refresh_comments
	# FILTERED_BY assoc_filter
	# params[:num_comments]
	def refresh_comments
		@corpus = Corpus.find_by_id(params[:id])
		num_comments_on_page = params[:num_comments].to_i
		num_comments = @corpus.comments.length

		respond_to do |format|
			format.json do
				if(num_comments_on_page != num_comments)
					diff = num_comments - num_comments_on_page

					if(diff > 0) #comments added
						new_comments = @corpus.comments.where("user_id != ?", current_user().id).limit(diff)

						if new_comments
							new_comments.map! do |com|
								render_to_string(:partial => 'comment', :formats => [:html], 
								:locals => {:comment => com})
							end
							render :json => {:ok => true, :num => num_comments, :add => true, :comms => new_comments}
						else
							render :json => {:ok => false, :num => num_comments}
						end
					else #comments removed
						# CURRENTLY UNSUPPORTED
						render :json => {:ok => false, :add => false, :num => num_comments}
					end
				else #comments = comments_on_page
					render :json => {:ok => false, :num => num_comments}
				end
			end
		end
	end

	# GET /corpora/1/view_history
	#
	def view_history
		@corpus = Corpus.find_by_id(params[:id])
		Dir.chdir Rails.root

		@revisions = @corpus.svn_revisions
		@rawlog = @corpus.svn_log
		@commits = @corpus.svn_commits_array

		respond_to do |format|	
			format.html
		end
		
	end
	
	
	# GET corpora/1/add_member
	# Ajax - Adds Member. i.e.
	# 
	# params[:id] = Corpus.id
	# params[:email] = 's.f.reza@gmail.com'
	# params[:role]  = 'owner'
	#
	# FILTERED_BY: owner_filter
	#
	def add_member
		@corpus = Corpus.find_by_id(params[:id])

		errors = []
		
		memHash = params[:member]
		if errors.length == 0 && !memHash
			errors.push("Invalid parameter format")
		end

		role = nil
		role = memHash[:role] if errors.length == 0
		
		if errors.length == 0 && ( !role || role.blank? || !(Membership.roles.include?(role)) )
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
		
		
		membership = Membership.where(:corpus_id => @corpus.id, :user_id => @member.id).first if errors.length == 0
		
		if errors.length == 0 && membership != nil
			errors.push("Membership already exists")
		end
		
		
		if errors.length == 0
			membership = Membership.create(:user_id => @member.id, :corpus_id => @corpus.id, :role => role)
		end
			
		respond_to do |format|
			format.html { redirect_to manage_members_corpus_path(@corpus)}
			
			format.json do
				if(errors.length == 0)
					render :json => {:ok => true, :resp => render_to_string(:partial => 'member', :layout => false, :locals => {:mem => membership}, :formats => [:html]) }
				else
					render :json => {:ok => false, :resp => "#{errors.join("\n")}"}
				end
			end
			
		end
	end
	
	# GET corpora/1/update_member
	# Ajax - Updates role of _existing_ member
	#
	# params[:id] = Corpus.id
	# params[:mem_id] = '2'
	# params[:role] = 'owner'
	#
	# FILTERED_BY: owner_filter
	#
	def update_member
		#To-Do: More Error Checking
		membership = Membership.find_by_id(params[:mem_id])
		role = params[:role]
		
		respond_to do |format|
			format.json do
				if membership && Membership.roles.include?(role)
					membership.role = role
					membership.save
					render :json => {:ok => true, :id => membership.id }	
				else
					render :json => {:ok => false, :id => membership.id, :role => membership.role}
				end
			end
		end
	end
	
	# GET corpora/1/remove_member
	# Ajax - Removes Member i.e
	#
	# params[:id] = Corpus.id
	# params[:mem_id] = '2'
	# ROLES NOT NECESSARY
	#
	# FILTERED_BY: owner_filter
	#
	def remove_member
		membership = Membership.find_by_id(params[:mem_id])

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
	
	# GET /corpora/new
	# GET /corpora/new.json
	def new
		@corpus = Corpus.new
		session[:resumable_filename] = nil

		respond_to do |format|
			format.html # new.html.erb
			format.json { render json: @corpus }
		end
	end

	# GET /corpora/1/edit
	def edit
		@corpus = Corpus.find(params[:id])
		session[:resumable_filename] = nil
	end
  
	# GET /corpora/1/download
	def download
		@corpus = Corpus.find(params[:id])

		@filename = params[:name]
		#To-Do: Error/Evil checking

		archive_path = "#{@corpus.archives_path}/#{@filename}"

		if @filename =~ /^\+(\d+)/
			version = $1.to_i
			@corpus.svn_prepare_version_for_download(version)
			archive_path = @corpus.get_archive(version)
			if(archive_path)
				send_file archive_path
			else
				flash[:notice] = "Your archive is being prepared. Please check back in a few minutes."
				redirect_to @corpus
			end

		elsif invalid_filename?(@filename) || !File.file?(archive_path)
			redirect_to '/perm'
		else
			send_file archive_path
		end
	end

	def browse
		Dir.chdir Rails.root

		@corpus = Corpus.find_by_id(params[:id])

		@rpath = params[:path] || "/"
		@rpath.gsub!("..", "");

		dir = "#{@corpus.head_path}#{@rpath}"
		dir.chop! if dir.length > 1 && dir[-1] == '/'

		unless File.exists?(dir) || Dir.exists?(dir)
			redirect_to '/perm'
			return
		end

		if !File.directory?(dir)
			dir.gsub!(/#{@corpus.head_path}/, '')
			rd = "/corpora/#{@corpus.id}/single_download?path=#{dir}"
			logger.info "**************#{rd}"
			redirect_to rd
			return
		end

		@files = Dir.glob("#{dir}/*").sort {|a,b| a.downcase <=> b.downcase}.partition{|f|File.directory?(f)}.flatten

		#---retroactive patch for old corpora---
		if(@files.empty? && !Dir.glob(@corpus.archives_path).empty?)
			retro_browse_patch()
			@files = Dir.glob("#{dir}/*")
		end
	end

	def single_download
		@corpus = Corpus.find_by_id(params[:id])
		
		@rpath = params[:path] || "/"
		@rpath.gsub!("..", "");

		file = "#{@corpus.head_path}#{@rpath}"
		file.chop! if file.length > 1 && file[-1] == '/'

		if invalid_filename?(file) || !File.exists?(file) || !File.file?(file)
			redirect_to '/perm'
			return
		end

		if params[:noview]
			send_file file
			return
		end

		@rpath = File.dirname(@rpath)
		@rpath = "/" if @rpath.blank?

		dir = "#{@corpus.head_path}#{@rpath}"

		@files = Dir.glob("#{dir}/*")
		@file = file
		@ext = File.extname(@file)
		@ext = ".txt" if `file #{File.expand_path(@file)}` =~ /ASCII/

		if [".md", ".txt", ".wav"].include?(@ext)
			unless @ext == ".wav"
				@content = ""
				File.open(file, "r") do |f|
					@content = f.read
				end
			end
			
			render :browse
			return
		end

		send_file file
	end

	
	# POST /corpora/:id/single_file_upload
	# resumable file upload in session[:resumable_filename]
	# commit message in params[:msg]
	# rpath
	def single_upload
		@corpus = Corpus.find_by_id(params[:id])

		Dir.chdir Rails.root

		@rpath = params[:rpath] || "/"
		@rpath.gsub!("..", "");
		dir = "#{@corpus.head_path}#{@rpath}"
		dir.chop! if dir.length > 1 && dir[-1] == '/'
		unless Dir.exists?(dir) && File.directory?(dir)
			redirect_to '/perm'
			return
		end

		resumable_filename_list = session[:resumable_filenames]
		resumable_filepath_list = session[:resumable_filepaths]

		logger.info "***RESUMABLE FILES COUNT: #{resumable_filename_list.length}"
		logger.info "***RESUMABLE FILES: #{resumable_filename_list}"


		msg = params[:msg]
		msg = "" unless msg
		msg += "\n"
		resumable_filename_list.each do |fname|
			msg += "\nUploaded #{@rpath if @rpath != '/'}/#{fname}"
		end

		msg = current_user().commit_header + msg

		files = `svn ls #{@corpus.svn_file_url}#{@rpath if @rpath != '/'}`.split("\n")
		logger.info "***************FILES = #{files}"

		if resumable_filename_list.length == 1 && !files.include?(resumable_filename_list[0])
			#SPECIAL CASE, ADD FILE THROUGH IMPORT
			repo_target = "#{@corpus.svn_file_url}#{@rpath if @rpath != '/'}/#{resumable_filename_list[0]}"
			system("svn import ./#{resumable_filepath_list[0]} #{repo_target} -m '#{msg}'")
			FileUtils.rm("./#{resumable_filepath_list[0]}")
			# TO-DO: CALL TO CLEAN UP CHUNKS
		elsif resumable_filename_list.length > 1
			logger.info("***SVN STAMP***")
			@corpus.prepare_upload_stage
			resumable_filename_list.each_with_index do |fname, index|
				FileUtils.mv("./#{resumable_filepath_list[index]}", "./#{@corpus.tmp_path}/#{fname}")
			end
			@corpus.rsync_tmp_and_upload_stage()

			Dir.chdir @corpus.upload_stage_path
			svn_stamp_commands()
			msg += "\n\n**PRE-COMMIT STATUS**\n" + `svn status`
			logger.info("svn commit -m #{Shellwords.escape(msg)}")
			safe_shell_execute("svn commit -m #{Shellwords.escape(msg)}")
			Dir.chdir Rails.root

			clear_directory(@corpus.tmp_path)
			@corpus.remove_upload_stage
		end

		Dir.chdir @corpus.head_path
		`svn update`
		Dir.chdir Rails.root

		redirect_to "/corpora/#{@corpus.id}/browse?path=#{@rpath}"
	end

	# POST /corpora/:id/single_rename
	# renames target file or folder in rpath
	# TODO: Add to Filters
	# @param rpath
	# @param newname
	def single_rename
		@corpus = Corpus.find_by_id(params[:id])

		@rpath = params[:rpath] || "/"
		@rpath.gsub!("..", "")

		if @rpath == "/"
			redirect_to '/perm'
			return
		end

		newname = params[:newname]
		if !newname || invalid_filename?(newname)
			redirect_to '/perm'
			return
		end

		file = "#{@corpus.head_path}#{@rpath}"
		file.chop! if file.length > 1 && file[-1] == "/"

		if(invalid_filename?(file) || !File.exists?(file))
			logger.info "*************INVALID FILE*********** #{file}"
			redirect_to '/perm'
			return
		end

		directory = File.dirname(file).gsub(/^#{@corpus.head_path}/, "")
		directory = "/" if directory.blank?

		filename = File.basename(file)

		if(filename == newname)
			redirect_to "/corpora/#{@corpus.id}/browse?path=#{directory}"
			return
		end

		fullpath = "#{directory}#{'/' if directory != '/'}#{filename}"
		renamepath = "#{directory}#{'/' if directory != '/'}#{newname}"

		repo_target = "#{@corpus.svn_file_url}#{fullpath}"
		rename_target = "#{@corpus.svn_file_url}#{renamepath}"

		msg = "\Renamed #{fullpath} to #{renamepath}"
		msg = current_user().commit_header + msg
		

		logger.info("*******************REPO TARGET = #{repo_target}")
		logger.info("*******************RENAME TARGET = #{rename_target}")
		logger.info("*******************MSG = #{msg}")

		`svn move #{repo_target} #{rename_target} -m "#{msg}"`

		Dir.chdir Rails.root
		Dir.chdir @corpus.head_path
		`svn update`
		Dir.chdir Rails.root

		redirect_to "/corpora/#{@corpus.id}/browse?path=#{directory}"
	end

	# DELETE /corpora/:id/single_delete
	# deletes target file or folder in
	# rpath
	def single_delete
		@corpus = Corpus.find_by_id(params[:id])

		@rpath = params[:rpath] || "/"
		@rpath.gsub!("..", "")

		if @rpath == "/"
			redirect_to '/perm'
			return
		end

		file = "#{@corpus.head_path}#{@rpath}"
		file.chop! if file.length > 1 && file[-1] == "/"

		if invalid_filename?(file) || !File.exists?(file)
			logger.info "*************INVALID FILE*********** #{file}"
			redirect_to '/perm'
			return
		end

		directory = File.dirname(file).gsub(/^#{@corpus.head_path}/, "")
		directory = "/" if directory.blank?
		filename = File.basename(file)
		fullpath = "#{directory}#{'/' if directory != '/'}#{filename}"

		repo_target = "#{@corpus.svn_file_url}#{fullpath}"

		msg = "\Deleted #{fullpath}"
		msg = current_user().commit_header + msg

		

		logger.info("*******************REPO TARGET = #{repo_target}")
		logger.info("*******************MSG = #{msg}")

		`svn delete #{repo_target} -m "#{msg}"`

		Dir.chdir Rails.root
		Dir.chdir @corpus.head_path
		`svn update`
		Dir.chdir Rails.root

		redirect_to "/corpora/#{@corpus.id}/browse?path=#{directory}"
	end


	# POST /corpora
	def create
		paramHash = params[:corpus]
		owner_text = paramHash.delete('owner')
		@corpus = Corpus.new(paramHash)
		
		rfname = session[:resumable_filename]
		@file = rfname ? File.new(rfname) : nil
		
		logger.info "FILE = #{@file}"


		@corpus.valid? #note to self, overwrites existing errors
		
		#Allow for Empty Corpus
		#if !@file
		#	@corpus.errors[:upload_file] = " is missing"
		#end

		owner_email = ""
		if owner_text =~ /\<(.+)\>/
			owner_email = $1
		end

		@owner = User.find_by_email(owner_email);
		if !@owner
			@corpus.errors[:owner] = " does not exist. Please invite owner. "  	
		end

		
		
		if @corpus.errors.none? && create_corpus("Initial") && @corpus.save
			Membership.create(:user_id => @owner.id, :corpus_id => @corpus.id, :role => 'owner');

			#If the License does not exist add the License
			license_text = paramHash['license']
			license = License.find_by_name(license_text)
			License.create(:name => license_text) unless license

			
			#format.html { redirect_to @corpus, notice: 'Corpus was successfully created.' }
			render :json => {:ok => true, :id => @corpus.id}
		else
			
			delete_archive(@archive) if @archive
			
			#format.html { render action: "new" }
			render :json => {:ok => false, :errors => @corpus.errors.to_a}
		end

		clear_directory(@corpus.tmp_path) if @corpus.utoken
	end
 
	# POST /corpora/1 
	# This is currently used for edits
	#
	# FILTERED_BY: owner_filter
	#
	def update
		@corpus = Corpus.find(params[:id])
		msg = params[:msg]
		
		msg.gsub!(/(\r+\n+)+/m, "<br/>") if msg
		
		rfname = session[:resumable_filename]
		@file = rfname ? File.new(rfname) : nil
		
		logger.info "---------------FILE = #{@file}"

		@corpus.valid?

		if @corpus.update_attributes(params[:corpus]) && create_corpus(msg) && @corpus.save
			#format.html { redirect_to @corpus, notice: 'Corpus was successfully updated.' }
			#If the License does not exist add the License
			license = License.find_by_name(@corpus.license)
			License.create(:name => @corpus.license) unless license

			render :json => {:ok => true, :id => @corpus.id}
		else
			delete_archive(@archive) if @archive
			#format.html { render action: "edit" }
			render :json => {:ok => false, :errors => @corpus.errors.to_a}
		end
		clear_directory(@corpus.tmp_path) if @corpus.utoken
	end

	# DELETE /corpora/1
	# DELETE /corpora/1.json
	#
	# FILTERED_BY: owner_filter
	#
	def destroy
		@corpus = Corpus.find(params[:id])
		@corpus.destroy


		respond_to do |format|
			format.html { redirect_to corpora_url }
			format.json { head :no_content }
		end
	end
  
	#---------------------------------------------------------------------------
	private #-------------------------------------------------------------------
	#---------------------------------------------------------------------------
  
  	def create_corpus(msg = "unspecified")
		require 'shellwords'
		Dir.chdir(Rails.root)
		
		# create corpora directory if necessary
		Dir.mkdir Corpus.corpora_folder unless Dir.exists? Corpus.corpora_folder
		
		# Generate uToken # This is redundant REMOVE/REFACTOR - SFR
		@corpus.utoken = gen_unique_token() unless @corpus.utoken 
		@corpus.create_dirs
		
		return true unless @file 
		#-------------We're done if there's no file-----------------------
		logger.info("FILE_PATH = #{@file.path}")
		archive_ext = get_archive_ext(@file.path);
		logger.info("FILE_EXT = #{archive_ext}")

		unless archive_ext
			@corpus.errors[:file_type] = "must be zip"
			return false
		end
		
		#------------Locking for Multiple Users----------------------------
		unless Dir.glob(@corpus.tmp_path + "/*").empty?
			@corpus.errors[:upload_in_use] = ": Please try again in just a minute."
			return false
		end
		
		#---------Extract Archive-------------------------------------------------
		# Archive should be deleted should this function return false
		# at any point
		#-------------------------------------------------------------------------
		archive_name = @corpus.safe_name
		version = @corpus.svn_revisions + 1
		
		@archive = @corpus.archives_path + "/#{archive_name}.#{version}.#{archive_ext}"

		# Move the file to archive folder
		FileUtils.mv(@file.path, @archive)
		

		begin
			if archive_ext == "zip"
				unzip(@archive, @corpus.tmp_path)
			end
		rescue => exception
			@corpus.errors[:internal] = " issue extracting your archive #{exception}"	
			#----------
			File.delete @archive if File.exists?(@archive) && !File.directory?(@archive)
			return false
		end

		#----tmp directory is ready for processing----------------------------------------

		@corpus.prepare_upload_stage
		@corpus.rsync_tmp_and_upload_stage

		msg = current_user().commit_header + msg

		if Dir.glob(@corpus.svn_path + "/*").empty?
			# Initial commit
			Dir.chdir Rails.root

			logger.info "svnadmin create #{@corpus.svn_path}"
			`svnadmin create #{@corpus.svn_path}` #initialize svn storage

			Dir.chdir @corpus.upload_stage_path
			logger.info "svn import . #{@corpus.svn_file_url} -m #{Shellwords.escape(msg)}"
			`svn import . #{@corpus.svn_file_url} -m #{Shellwords.escape(msg)}`

			Dir.chdir Rails.root
		else
			Dir.chdir Rails.root
			Dir.chdir @corpus.upload_stage_path
			
			# Check if tmp is a valid SVN Working Copy
			unless Dir.exists? "./.svn"
				@corpus.errors[:your_upload] = " is not a recent svn working copy"
				#-----------
				return false
			end
			
			svn_stamp_commands()

			logger.info("svn merge --dry-run -r BASE:HEAD .")
			unless safe_shell_execute('svn merge --dry-run -r BASE:HEAD .')	
				return false
			end

			msg += "\n\n**PRE-COMMIT STATUS**\n" + `svn status`
			logger.info("svn commit -m #{Shellwords.escape(msg)}")

			unless safe_shell_execute("svn commit -m #{Shellwords.escape(msg)}")
				return false
			end

			Dir.chdir Rails.root
		end


		Dir.chdir @corpus.head_path

		`svn update`

		# logger.info "svn co #{@corpus.svn_file_url} ."
		# `svn co #{@corpus.svn_file_url} .`

		Dir.chdir Rails.root

		#------------------LOCKED------------------------------------------------------------
		# /tmp Directory Locked. Must UNLOCK after this method is called
		#------------------------------------------------------------------------------------

		@corpus.remove_upload_stage

		#----------------------------UNLOCKED--------------------------------------
		return true
		#--------------------------------------------------------------------------
	end

	def svn_stamp_commands()
			# Forcefully add all new files
			logger.info("svn add . --force")
			`svn add . --force`	

			# If anything is still untracked '?' then add it
			logger.info("svn st | grep ^\? | awk '{print $2}' | xargs -r svn add")
			`svn st | grep ^\? | awk '{print $2}' | xargs -r svn add`

			# If anything is missing '!' then mark for deletion
			logger.info("svn st | grep ^\! | awk '{print $2}' | xargs -r svn delete --force")
			`svn st | grep ^\! | awk '{print $2}' | xargs -r svn delete --force`
			
			# TO-Do:
			# http://vcs.atspace.co.uk/2012/06/20/missing-pristines-in-svn-working-copy/
			# until then enable overwrite
	end

	def retro_browse_patch
		Dir.chdir(Rails.root)
		@archive_names = Dir.entries(@corpus.archives_path).select {|n| n != ".." && n != "." }

		#--Sort from highest to lowest Version
		@archive_names.sort! do |a, b|
			logger.info("a=#{a} b=#{b}")
			x = a.gsub(/\.#{get_archive_ext(a)}$/, '')[/\d+$/].to_i
			y = b.gsub(/\.#{get_archive_ext(b)}$/, '')[/\d+$/].to_i
			y <=> x
		end
		unless @archive_names.empty?
			unzip("#{@corpus.archives_path}/#{@archive_names[0]}", "#{@corpus.head_path}")
		end
	end
	
	def safe_shell_execute(string)
			require 'open3'
			stdin, stdout, stderr = Open3.popen3(string)
			
			out_lines = stdout.readlines
			err_lines = stderr.readlines
			
			conflicts = []
			
			if out_lines
				out_lines.each do |line|
					conflicts << line.gsub(/^\s*C\s+/, '') if line =~ /^\s*[C]\s+/
				end
			end
			
			if conflicts.size > 0
				conflicts.each do |c|
					@corpus.errors[:file_conflict] = " on #{c}"
				end
				
				@corpus.errors[:conflicts] = " exist. #{string}"
				
				return false
			end
			
			if err_lines && !err_lines.blank? 
				err_lines = err_lines.split("\n")
				err_lines.flatten! if err_lines.kind_of?(Array)
				
				err_lines.each do |e|
					@corpus.errors[:SVN_Error] = e if e
				end
				
				@corpus.errors[:SVN_Errors] = " found. #{string}"
				return false
			end
	
			return true
	end
	
	# Used to delete the most recent uploaded archive because something went wrong
	def delete_archive(archive)
		Dir.chdir Rails.root
		`rm -f #{archive}` if File.exists?(archive)
	end
		
	def clear_directory(path)
		Dir.chdir Rails.root
		if File.exists?(path)
			Dir.chdir path
			`rm -rf * .*` if !Dir.glob("./*").empty?
		end
		Dir.chdir Rails.root
	end
  
	def unzip(zip_path, xtract_dir)
		Dir.chdir Rails.root
		
		files = `unzip -l #{zip_path}`.split("\n")
		files.shift(3); files.pop(2);
		files.map! {|f| f[30..-1]}

		`unzip #{zip_path} -d #{xtract_dir}`
		container = container(files)
		logger.info "**CONTAINER = #{container}"

		if container
			`mv #{xtract_dir}/#{container} #{xtract_dir}/#{@corpus.utoken}` #Safety - in case container contains folder with same name as container
			`mv #{xtract_dir}/#{@corpus.utoken}/** #{xtract_dir}`
			`rm -rf #{xtract_dir}/#{@corpus.utoken}`
		end
	end
  
	def untar(tarpath, xtract_dir)
		Dir.chdir Rails.root
		
		strip = "--strip 1";
		files = `tar tf #{tarpath}`.split("\n")
		strip = "" if container(files) == nil
		#-------------------------------------------
		logger.info "tar zxf #{tarpath} -C #{xtract_dir} #{strip}"
		system("tar zxf #{tarpath} -C #{xtract_dir} #{strip}");
	end
  
  
  
	# returns the name of the container if there is one
	# returns nil otherwise (when there is no container)
	def container(files)
		container = files[0][/^[^\/]+\//]
		files.each do |f|
			if(f[/^[^\/]+\//] != container)
				return nil
			end
		end
		return container
	end
  
	def gen_unique_token()
		utoken = ""
		begin
			utoken = SecureRandom.uuid
		end while Corpus.where(:utoken => utoken).exists?
		return utoken
	end
  
	def get_archive_ext(string)
		return "zip"		if string =~ /\.zip$/
		return nil
	end
  
	def file_count(dir)
		return Dir.glob("#{dir}/*").length
	end
  
	def invalid_filename?(name)
		return true if name == nil
		return true if name.blank?
		return true if name =~ /^\.\./
		return true if name =~ /\~/
		return false
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
		@corpus = Corpus.find_by_id(params[:id])
		redirect_to '/perm' unless @corpus
	end
  
  	# Allows only owners
  	# Is applied in combination with user_filter
	def owner_filter
		@corpus = Corpus.find_by_id(params[:id])

		#Dont filter super_key holders
		return if current_user().super_key != nil

		redirect_to '/perm' unless @corpus && @corpus.owners.include?(current_user())
	end

	# Allows owners || approvers || members
	def assoc_filter
		@corpus = Corpus.find_by_id(params[:id])

		# Dont filter super_key holders
		return if current_user().super_key != nil

		redirect_to '/perm' unless @corpus && @corpus.owners.include?(current_user()) || @corpus.approvers.include?(current_user()) || @corpus.members.include?(current_user())
	end
end
