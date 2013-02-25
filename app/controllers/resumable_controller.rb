class ResumableController < ApplicationController
	require 'shellwords'

	before_filter :user_filter, :except => [:resumable_test]

	FOLDER = "resumable_uploads"

	def resumable_test

	end

	# GET /resumable_upload_ready
	# check to see if an upload is ready
	def resumable_upload_ready
		target_filename = params[:filename]
		target_size = params[:size]

		unless target_filename && target_size
			render :json => {:ok => false, :msg => "Invalid Arguments.\nfilename = #{target_filename}\ntarget_size=#{target_size}"}
			return
		end

		target_filename = Shellwords.escape(target_filename)
		target_filename = "#{FOLDER}/#{target_filename}"

		target_size = target_size.to_i

		unless File.exists?(target_filename)
			render :json => {:ok => false, :msg => "#{target_filename} does not exist"}
			return
		end

		if File.size?(target_filename) < target_size
			render :json => {:ok => false, :msg => "File is being put together. #{File.size?(target_filename)} / #{target_size}"}
			return
		end

		if File.size?(target_filename) > target_size
			render :json => {:ok => false, :msg => 'File is bigger than expected. Something has gone wrong.'}
			return
		end

		render :json => {:ok => true, :msg => "Done. Your file is ready."}

	end

	# GET /resumable_upload_combine
	def resumable_upload_combine
		filename = params[:filename]
		identifier = params[:identifier]
		numChunks = params[:numChunks]

		unless filename && identifier && numChunks
			render :json => {:ok => false, :msg => "Invalid Arguments.\nfilename = #{filename}\nidentifier = #{identifier}\nnumChunks = #{numChunks}"}
			return
		end

		@resumableFilename = "#{Shellwords.escape(filename)}"
		@resumableIdentifier = identifier
		@numberOfChunks = numChunks.to_i

		unless File.exists?(@resumableFilename)
			combine_chunks!
			render :json => {:ok => true, :msg => "Combining Chunks"}
			return
		end

		render :json => {:ok => false, :msg => "File already combined."}
	end


	# POST /upload 
	# Used with Resumable.js
	# Used to Upload stuff
	def post_resumable_upload
		@resumableChunkNumber = params['resumableChunkNumber'].to_i
		@resumableChunkSize = params['resumableChunkSize'].to_i
		@resumableCurrentChunkSize = params['resumableCurrentChunkSize'].to_i
		@resumableTotalSize = params['resumableTotalSize'].to_i
		@resumableIdentifier = params['resumableIdentifier']
		@resumableFilename = params['resumableFilename']
		@resumableRelativePath = params['resumableRelativePath']
		@resumableFile = params['file']
		@resumableFileSize = @resumableFile.size
		@numberOfChunks = [1, @resumableTotalSize/@resumableChunkSize].max

		# render :json => {:fileSize => @resumableFileSize}

		unless @resumableFile
			render :text => 'invalid_resumable_request'
			return
		end

		validation = validateRequest()

		unless validation == :valid
			render :text => validation
			return
		end

		chunkFileName = getChunkFilename(@resumableIdentifier, @resumableChunkNumber)

		Dir.mkdir FOLDER unless Dir.exists? FOLDER

		# Write file to FOLDER
		File.open(chunkFileName, "wb") {|f| f.write(@resumableFile.read) }

		if(all_chunks_here?)
			logger.info "***ALL CHUNKS HERE***"
			# combine_chunks!
			logger.info("***DONE***")
			render :json => {}
		else
			logger.info("***partly done***")
			render :json => {}
		end

	end

	# GET /upload
	# Used with Resumable.js
	# Used to Test Chunks
	def get_resumable_upload
		@resumableChunkNumber = params['resumableChunkNumber'].to_i
		@resumableChunkSize = params['resumableChunkSize'].to_i
		@resumableCurrentChunkSize = params['resumableCurrentChunkSize'].to_i
		@resumableTotalSize = params['resumableTotalSize'].to_i
		@resumableIdentifier = params['resumableIdentifier']
		@resumableFilename = params['resumableFilename']
		@resumableRelativePath = params['resumableRelativePath']
		@resumableFile = nil
		@resumableFileSize = nil 
		@numberOfChunks = [1, @resumableTotalSize/@resumableChunkSize].max

		# We don't care about the file chunk itself
		# when testing to see if it exists server-side

		if(validateRequest() == :valid)
			if(File.exists?(getChunkFilename(@resumableIdentifier, @resumableChunkNumber)))
				render :text => "found", :status => 200
			else
				render :text => "not_found", :status => 404
			end
		else
			render :text => "not_found", :status => 404
		end
	end

	private

	#---------Helpers----------------------------------------------
	def all_chunks_here?
		total = 0;
		(1..@numberOfChunks).each do |chunkID|
			chunkPath = getChunkFilename(@resumableIdentifier, chunkID)
			return false unless File.exists?(chunkPath)
			chunk_size = File.size?(chunkPath)
			total += (chunk_size) ? chunk_size : 0
		end
		return false unless total == @resumableTotalSize
		return true
	end

	def combine_chunks!
		files = (1..@numberOfChunks).map {|cid| getChunkFilename(@resumableIdentifier, cid)}
		output_filename = "#{FOLDER}/#{Shellwords.escape(@resumableFilename)}"
		resumable_globstring = getChunkGlobString(@resumableIdentifier)
		cmd = "cat #{resumable_globstring} > #{output_filename}"
		logger.info("***#{cmd}")
		`#{cmd}`
		session[:resumable_filename] = output_filename
		session[:resumable_leftovers] = resumable_globstring
	end

	def validateRequest()
		cleanIdentifier!(@resumableIdentifier)

		# Check if request is sane
		return :non_resumable_request if
			@resumableChunkNumber <= 0 ||
			@resumableChunkSize <= 0 ||
			@resumableTotalSize <= 0 ||
			@resumableIdentifier == nil || @resumableIdentifier.length <= 0 ||
			@resumableFilename == nil || @resumableFilename.length <= 0;

		return :invalid_chunk_number if(@resumableChunkNumber > @numberOfChunks)

		# We don't have an upper limit on the file size

		# Different set of tests for when validateRequest()
		# is called from post_resumable_upload
		if(@resumableFileSize != nil) 
			if(@resumableChunkNumber<@numberOfChunks && @resumableFileSize!=@resumableChunkSize)
				# the chunk is not the last chunk but the chunk is not the correct size
				return :invalid_chunk_size
			end

			if (@resumableChunkNumber>1 && @resumableChunkNumber==@numberOfChunks && 
				@resumableFileSize != ((@resumableTotalSize % @resumableChunkSize) + @resumableChunkSize))

				# the last chunk should be the size of what's left modulo chunkSize
				# plus the size of a normal chunk
				# but it's not

				return :invalid_chunk_remainder
			end

			if(@numberOfChunks == 1 && @resumableFileSize != @resumableTotalSize)
				# there's only one chunk but it's not the right size
				return :invalid_single_chunk_size
			end
		end

		return :valid

	end

	def cleanIdentifier!(identifier)
		identifier.gsub!(/[^0-9A-Za-z_-]/, "")
	end

	def getChunkFilename(identifier, chunkNumber)
		cleanIdentifier!(identifier)
		return "#{FOLDER}/resumable-#{identifier}.%020d" % chunkNumber
	end

	def getChunkGlobString(identifier)
		cleanIdentifier!(identifier)
		return "#{FOLDER}/resumable-#{identifier}.*"
	end


	#---Filters--
	def user_filter
		redirect_to '/perm' unless user_signed_in?
	end
end
