class UsersMailer < ActionMailer::Base
  default from: "info@reciprosody.org"
  
	def invitation_mail(from_user, to_user, tmp_password)
  	@from_user = from_user
  	@to_user = to_user
  	@tmp_password = tmp_password
  	
  	mail(:from => @from_user.email,
         :to => @to_user.email,
         :subject => "Reciprosody - An invitation from " + @from_user.name)
  end
  
end
