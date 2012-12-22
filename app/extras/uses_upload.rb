module UsesUpload

	# Returns the upload file from /upload
	# Returns nil on Error
	# Immediately sets session[:upload_file] to nil
	def get_upload_file
		Dir.chdir Rails.root
		filePath = session[:upload_file]
		session[:upload_file] = nil
		return File.new(filePath) if filePath
		return nil
	end

	# Removes an upload/uuid directory
	# Necessary for clean-up
	# Returns true on Success
	# Returns false on Error
	def remove_upload_file(file)
		Dir.chdir Rails.root
		filePath = file.path
		if filePath =~ /\/upload\/(.+)\/(.+)$/
			token = $1
			Dir.chdir "./upload"
			`rm -rf #{token}`
			return true
		else
			return false
		end
	end
end
