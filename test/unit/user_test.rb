require 'test_helper'

class UserTest < ActiveSupport::TestCase
	setup do
		@corpus = corpora(:one)
		@user = users(:syed)
	end

	test "the truth" do
		assert true
	end

	test "user action on corpus" do
		@corpus.user_action_from(@user, :download)
	end
end
