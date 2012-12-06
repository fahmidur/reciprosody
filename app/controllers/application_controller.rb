class ApplicationController < ActionController::Base
	protect_from_forgery
	
	def help
		Helper.instance
	end
	
	class Helper
		include Singleton
		include ActionView::Helpers::DateHelper
		include ActionView::Helpers::TextHelper
	end
end
