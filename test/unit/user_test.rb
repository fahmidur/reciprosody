require 'test_helper'
require 'securerandom'
class UserTest < ActiveSupport::TestCase
	setup do
		@corpus = corpora(:one)
		@user = users(:syed)
	end

	test "the truth" do
		assert true
	end

	test "user action on corpus" do
		@corpus.user_action_from(
			@user, 
			:download,
		)
	end

	#
	# Tests the Weighted Search
	# for the User Model
	#
	test "user.wsearch('<impossible string>') should return an empty array" do
		impossible_string = SecureRandom.uuid * 5
		result = User.wsearch(impossible_string)
		assert result.class.to_s == 'Array'
	end
end
