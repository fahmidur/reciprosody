module UploadHelper

def setup_upload
	session[:upload_token] = SecureRandom.uuid
end
  
end
