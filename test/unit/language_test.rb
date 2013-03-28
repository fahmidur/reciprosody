require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
	test "empty language without name should not save" do
		lang = Language.new
		assert !lang.name
		assert !lang.save
	end

	test "completed language with name does save" do
		lang = Language.new
		lang.name = "Test Language"
		assert lang.name && lang.name.present?
		assert lang.save
	end
end
