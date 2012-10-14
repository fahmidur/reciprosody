class ApplicationController < ActionController::Base
  protect_from_forgery
  
  #to-do: complete logic in next cycle
  #before_filter :user_redirect, :only => [:index]
  
  def index
  	render '/index'
  end
  
  private
  
  def user_redirect
  	if user_signed_in?
  		redirect_to "/users/show"
  	end
  end
  
  
end
