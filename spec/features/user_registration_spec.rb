require 'spec_helper'

describe 'user registration' do 
	it "allows new users to register with an email address and password" do
		visit '/users/sign_up'

		fill_in "Name", :with => "Test Doe"
		fill_in "Email", :with => "s.f.reza+testdoe@gmail.com"
		fill_in 'user_password', :with => "testing"
		fill_in "Password confirmation", :with => "testing"

		click_button "Sign up"
		
		page.should have_content(/almost done/i)
	end
end