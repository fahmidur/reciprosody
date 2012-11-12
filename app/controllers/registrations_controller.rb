class RegistrationsController < Devise::RegistrationsController

	protected
	
	def after_inactive_sign_up_path_for(resource)
		'/welcome'
	end
		
end
