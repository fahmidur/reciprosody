class AdminsMailer < ActionMailer::Base
	default :from => 'info@reciprosody.org'

	def request_a_key(user, token)
		@user = user
		@token = token
		mail(:from => 'info@reciprosody.org', :to => 's.f.reza+reciprosody@gmail.com', :subject => 'Reciprosody::Key_Request for ' + user.name)
	end

	class Preview < MailView
		def request_a_key
			user = User.first();
			token = SecureRandom.uuid
			AdminsMailer.request_a_key(user, token)
		end
	end
end