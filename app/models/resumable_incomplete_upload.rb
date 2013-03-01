class ResumableIncompleteUpload < ActiveRecord::Base
	belongs_to :user
	attr_accessible :filename, :formdata, :identifier, :url, :user_id

	before_destroy :cleanup

	FOLDER = "resumable_uploads"

	def cleanup
		if identifier && identifier.present?
			FileUtils.rm_rf Dir.glob("#{FOLDER}/#{identifier}.*")
			filename.gsub!(/^[\.,\\,\/]*/, "")
			FileUtils.rm_f "#{FOLDER}/#{filename}" if identifier && identifier.present?
		end
	end 
end
