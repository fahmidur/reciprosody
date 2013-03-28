require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
	test "empty publication without title should not save" do
		pub = Publication.new
		assert !pub.save
	end

	test "completed valid publication should save" do
		pub = Publication.new
		pub.name = "Test Publication"
		pub.url = "http://www.google.com"
		assert pub.save
	end

	test "publication with invalid url does not save" do
		pub = Publication.new
		pub.name = "Test Publication"
		pub.url = "invalid url"
		assert !pub.save
	end
end
