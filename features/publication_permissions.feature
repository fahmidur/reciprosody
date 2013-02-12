Feature: Publications index page available when I am logged out
	The visitor should see the publication index page
	when they are not logged in
	They should see at minimum a page with an alert alert-info

	Scenario: User clicks on "Publication" top-level nav button
		Given I am on the logout page
		When I go to the publications page
		Then the page should have an alert-info


