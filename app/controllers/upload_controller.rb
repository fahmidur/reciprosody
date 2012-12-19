class UploadController < ApplicationController
  def upload_test
	@uid = SecureRandom.uuid
  end
  
  # POST upload handler
  # Returns JSON
  def ajx_upload
  	require 'shellwords'
  	
  	uid = params[:uid]
  	file = params[:file]
  	chunks = params[:chunks].to_i
	chunkID = params[:chunkID].to_i
	totalBytes = params[:totalSize].to_i
	fileName = Shellwords.escape(params[:fileName])
	
	Dir.chdir Rails.root
	Dir.mkdir "upload" unless Dir.exist? "upload"
	
	Dir.chdir "upload"
	Dir.mkdir uid unless Dir.exists? uid
	
	Dir.chdir uid
	File.open("%020d.chunk" % chunkID, "wb") {|f| f.write(file.read)}
	
	ok = true
	errors = []
	# pick an arbitrary thread to combine files
	if chunks == chunkID+1
		logger.info("chunks = #{chunks}, chunkID = #{chunkID}");
		logger.info("about to extract");
		
		baseTime = Time.now
		# wait a maximum of an hour for all chunks
		# to-do: make this dynamic: estimate max wait time as f(totalBytes)
		until chunks == Dir.glob("*.chunk").size
			if (Time.now - baseTime)/60 > 60
				ok = false;
				errors.push("Chunks took too long to arrive")
				break;
			end
		end
		
		baseTime == Time.now
		# wait for confirmation that all bytes were written to disk
		while true
			savedBytes = 0
			Dir.glob("*.chunk").each do |chunk|
				savedBytes += File.new(chunk).size
			end
			break if savedBytes >= totalBytes
			
			# should not take more than 10 minutes to write
			# thid data
			if (Time.now - baseTime)/60 > 10
				ok = false
				errors.push("Chunks took too long to write")
				break;
			end
		end
		
		`rm #{fileName}` if File.exists?(fileName)
		
		`cat *.chunk >> #{fileName}`
		
		`rm *.chunk`
	end
	
  	render :json => {:ok => ok, :errors => errors}
  end
  
end
