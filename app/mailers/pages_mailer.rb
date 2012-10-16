class PagesMailer < ActionMailer::Base
  default from: "info@reciprosody.com"
  
  def sug_mail(from, name, text)
  	@from = from
  	@name = name
  	@text = text
  	mail(:from => @from, :to => 's.f.reza+reciprosody@gmail.com', :subject => "Reciprosody::Suggestion - " + @name);
  end
end
