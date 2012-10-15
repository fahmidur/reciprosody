class PagesController < ApplicationController
	protect_from_forgery
	
	before_filter :user_redirect, :only => [:index]
  
  def index
  	
  end
  
  def about
  	
  end
  
  def faq
  	
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
  
  def contact
  	
  end
  
  private
  
  def user_redirect
  	if user_signed_in?
  		redirect_to '/user' #redirect to user "home page"
  	end
  end
  
end
