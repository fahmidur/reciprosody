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

  def message_mail(from_user, to_user, message_topic, message_body, message_id)
    @from_user = from_user
    @to_user = to_user
    @message_topic = message_topic
    @message_body = message_body
    @message_id = message_id
    
    mail(:from => "messages@reciprosody.org",
         :to => @to_user.email,
         :subject => "New Message From " + @from_user.name)
  end
  
  class Preview < MailView
    def message_mail
      from_user = User.all[0]
      to_user = User.all[1]

      UsersMailer.message_mail(from_user, to_user, "Test Topic", "Test body. This is only a test", 137)
    end
  end
end
