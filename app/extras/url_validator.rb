class UrlValidator < ActiveModel::EachValidator
	def validate_each(record, attribute, value)
		begin
			uri = URI.parse(value)
			unless(uri.kind_of?(URI::HTTP) || uri.kind_of?(URI::FTP))
				record.errors[attribute] << " must be HTTP or FTP"
			end
		rescue
			record.errors[attribute] << " invalid URL"
		end
		
	end
end