class UserSanitizer < Devise::ParameterSanitizer
	private
	def account_update
		default_params.permit(:name, :email, :password, :password_confirmation, :current_password)
	end

	def sign_up
		default_params.permit(:name, :email, :password, :password_confirmation)
	end
end