require 'test_helper'

class PublicationKeywordTest < ActiveSupport::TestCase
	test "should not save blank publication_keywords" do
		kw = PublicationKeyword.new
		assert !kw.save
	end
end
