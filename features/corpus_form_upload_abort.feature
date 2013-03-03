Feature: resumableAbort() removes all resumable items 
	After the user selects and uploads a file
	in corpus new or corpus edit
	If they invoke the abort action for that file
	Every resumable item chunks and/or combined files
	should be removed from the server-side resumable folder

	Scenario: User clicks on "abort" for an uploaded file
		Given I am logged in

		
