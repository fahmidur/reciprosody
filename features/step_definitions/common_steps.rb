require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am logged in$/ do
	visit path_to('the logout page')
	visit path_to('the login page')

	user = User.find_by_email("s.f.reza@gmail.com")
	password = 'testing'

	unless user
		user = User.new(
			:name => "Syed Reza", 
			:email => "s.f.reza@gmail.com",
			:password => password,
			:password_confirmation => "testing"
		);

		user.confirm!
		user.skip_confirmation!
		user.save
	end

	fill_in("Email", :with => user.email)
	fill_in("Password", :with => password)
	click_button("Sign in")
	page.should have_css('#hf-userID')
	find('#hf-userID').value.should_not == "NA"
end

Then /^the page should have an (.+)$/ do |class_name|
	page.should have_css(".#{class_name}")
end