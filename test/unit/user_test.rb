require 'test_helper'
require 'securerandom'
class UserTest < ActiveSupport::TestCase
	setup do
		@corpus = corpora(:one)
		@user = users(:syed)
		@onedoe = users(:one_doe)
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

	# Type-strict tests

	##
	# Tests the Weighted Search for User
	# this should return an empty string for
	# such an impossible string (repeat for all models)
	test "User.wsearch('<impossible string>') should return an empty array" do
		wsearch_test('User', impossible_string)
	end

	##
	# Test that User.insts
	# returns an Array of Institutions
	test "@user.insts returns an array and every element of the array is an Institution" do
		result = @user.insts
		assert result.class.to_s == 'Array'
		result.each do |r|
			assert r.class.to_s == 'Institution'
		end
	end

	##
	# test that getProp with impossible_string as key
	# returns nil
	#
	test "@user.getProp(impossible_string) should return nil" do
		ret = @user.getProp(impossible_string)
		assert ret == nil
	end

	##
	# test that setProp and getProp works to
	# set a key and then retrieve it
	test "@user.setProp('test-key', 'test-value') works" do
		@user.setProp('test-key', 'test-value');
		val = @user.getProp('test-key');
		assert val == 'test-value';
	end

	##
	# test that setProp with nil value
	# deletes a property
	test "@user.setProp('test-key') deletes 'test-key'" do
		@user.setProp('test-key', 'test-value');
		@user.setProp('test-key')
		assert @user.getProp('test-key') == nil
	end

	##
	# test that getProp with no args returns a
	# an array of all properties
	test "@user.getProp returns an array of all properties" do
		@user.setProp('test-key', 'test-value')
		ret = @user.getProp
		assert ret.class.to_s == 'ActiveRecord::Associations::CollectionProxy::ActiveRecord_Associations_CollectionProxy_UserProperty'
		ret.each do |prop|
			assert prop.class.to_s == 'UserProperty'
		end
	end

	##
	# test that commit_header returns a string
	test "@user.commit_header returns a string" do
		assert @user.commit_header.class.to_s == 'String'
	end

	##
	# test gravatar url is a valid url
	#
	test "@user.gravatar_url returns a valid url" do
		assert valid_url?(@user.gravatar_url(:png)) == true
	end

	##
	# test that insts string is a comma separated string 
	# and test that it's length matches the number of institions
	# the user has
	test "@user.insts_string returns a command separated string of valid size" do 
		str = @user.insts_string
		assert str.class.to_s == 'String'
		arr = str.split(',')
		assert arr.length == @user.institutions.length
	end

	##
	# test @user.shout returns safely for empty user set
	test '@user.shout should return safely when empty user set given' do
		@user.shout([], '', '')
	end

	##
	# test @user.shout works for not-empty user set
	# with nil faye proc
	test '@user.shout should returns safely for some set of users' do
		@user.shout([@onedoe], 'test-topic', 'test-body')
	end

	test 'User.supers returns a correct relation' do
		ret = User.supers
		assert ret.class.to_s == 'ActiveRecord::Relation::ActiveRecord_Relation_User'
	end

	test '@user.resumables returns a correct relation' do
		ret = @user.resumables
		assert ret.class.to_s == 'ActiveRecord::Relation::ActiveRecord_Relation_ResumableIncompleteUpload'
	end

	##
	# test all associated_<resources>
	test "@user.associated_* returns an array" do
		resources = ['corpora', 'publications', 'tools']
		resources.each do |r|
			ret = @user.send("associated_"+r)
			assert ret.class.to_s == 'Array'
		end
	end

	test '@user.email_format returns a string' do
		ret = @user.email_format
		assert ret.class.to_s == 'String'
	end
end
