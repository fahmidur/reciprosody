require 'test_helper'

class PublicationTest < ActiveSupport::TestCase
	test "should not save Publication without title" do
		pub = Publication.new
		assert !pub.save
	end
end
