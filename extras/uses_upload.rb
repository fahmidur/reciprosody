module UsesUpload
	def get_upload_file
		Dir.chdir Rails.root
		filePath = session[:upload_file]
		session[:upload_file] = nil
		return File.new(filePath) if filePath
		return nil
	end
end
