class PagesController < ApplicationController
	protect_from_forgery
	
	before_filter :user_redirect, :only => [:index]
  
  #----Static Pagse---
  def index
  end
  
  def about
  end
  
  def faq
  end
  
  def permission
  end
  
  def welcome
  end
  
  def how_to
  end

  def test_mail
    
  end
  
  #-- submit a new faq --
  def faq_submit
  	question = params[:question]
  	logger.debug "Question: #{question}"
  	if verify_recaptcha && !question.blank?
  		#save question to database
  		FaqQuestion.create(:question => question);
	  	render :json => {response: true, echo: question}
	  else
	  	render :json => {response: false, echo: question}
	  end
  end
  
  #-- sends an email to me +reciprosody_sug --
  def sug_submit
  	email = params[:email]
  	name = params[:name].split(/\W/).map(&:capitalize).join(" ")
  	text = params[:text][0]
  	
  	
  	logger.debug "Text = |#{text}|"
  	
  	errors = Hash.new(false)
  	errors[:cap] 		= !verify_recaptcha
  	errors[:email]	= !email_valid(email)
  	errors[:name]		= !name_valid(name)
  	errors[:text] 	= text.blank?
  	
  	okay = true
  	errors.each do |k, v|
  		if v == true
  			okay = false
  			break
  		end
  	end
  	if(okay)
  		#---send email---
	  	PagesMailer.sug_mail(email, name, text).deliver
  	end
  	
  	render :json => {:okay => okay, :errors => errors}
  	
  end
  
  def contact
	  	
  end
  
  private
  
  def name_valid(name)
  	return true if name =~ /\w+/
  	return false
  end
  
  def email_valid(email)
  	return true if email =~ /^.+\@.+\..+$/
  	return false
  end
  
  def user_redirect
  	if user_signed_in?
  		redirect_to '/user' #redirect to user "home page"
  	end
  end
  
end
