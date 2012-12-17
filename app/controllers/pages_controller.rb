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
  
  def upload_test
	@uid = SecureRandom.uuid
  end
  
  # POST upload handler
  # Returns JSON
  def ajx_upload
  	uid = params[:uid]
  	file = params[:file]
  	chunks = params[:chunks].to_i
	chunkID = params[:chunkID].to_i
	fileName = params[:fileName]
	
	Dir.chdir Rails.root
	Dir.mkdir "upload" unless Dir.exist? "upload"
	
	Dir.chdir "upload"
	Dir.mkdir uid unless Dir.exists? uid
	
	Dir.chdir uid
	File.open("%020d.chunk" % chunkID, "wb") {|f| f.write(file.read)}
	
	if chunks == chunkID + 1
		logger.info("chunks = #{chunks}, chunkID = #{chunkID}");
		logger.info("about to extract");
		sleep(1);
		
		`cat *.chunk >> #{fileName}`
	end
	
  	render :json => {:ok => true, :chunks => chunks}
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
