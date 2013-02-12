require File.expand_path(File.join(File.dirname(__FILE__), "..", "support", "paths"))

Given /^I am on (.+)$/ do |page_name|
	visit path_to(page_name)
end

When /^I go to (.+)$/ do |page_name|
	visit path_to(page_name)
end

Then /^the page should have an (.+)$/ do |class_name|
	page.should have_css(".#{class_name}")
end