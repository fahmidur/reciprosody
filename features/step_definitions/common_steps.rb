require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am logged in$/ do
	visit path_to('the logout page')
	visit path_to('the login page')

	new_user = User.new(
		:name => "Syed Reza", 
		:email => "s.f.reza@gmail.com",
		:password => "testing", 
		:password_confirmation => "testing"
	);

	new_user.confirm!
	new_user.skip_confirmation!
	new_user.save

	fill_in("Email", :with => 's.f.reza@gmail.com')
	fill_in("Password", :with => 'testing')
	click_button("Sign in")
	page.should have_css('#hf-userID')
	find('#hf-userID').value.should_not == "NA"
end

Then /^the page should have an (.+)$/ do |class_name|
	page.should have_css(".#{class_name}")
end