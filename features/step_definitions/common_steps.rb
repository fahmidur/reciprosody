require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am logged in$/ do
	visit path_to('the logout page')
	visit path_to('the login page')
	fill_in("Email", :with => 's.f.reza@gmail.com')
	fill_in("Password", :with => 'testing')
	click_button("Sign in")
end