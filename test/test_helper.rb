ENV["RAILS_ENV"] = "test"
require 'simplecov'
SimpleCov.start

require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require 'factory_girl'
<<<<<<< HEAD
=======
require 'uri'
>>>>>>> newfeatures


class ActiveSupport::TestCase
	# include Devise::TestHelpers
	
	# Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
	#
	# Note: You'll currently still have to declare fixtures explicitly in integration tests
	# -- they do not yet inherit this setting
	fixtures :all

	# Add more helper methods to be used by all tests here...
<<<<<<< HEAD
=======

	def wsearch_test(model_name, str)
		result = model_name.constantize.wsearch(str)
		assert result.class.to_s == 'Array'
	end

	def impossible_string
		return SecureRandom.uuid * 5
	end

	def valid_url?(url)
		!!URI.parse(url)
	rescue URI::InvalidURIError
		false
	end
>>>>>>> newfeatures
end
