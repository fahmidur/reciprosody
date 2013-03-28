require 'test_helper'

class LicenseTest < ActiveSupport::TestCase
  test "empty license without name should not save" do
		license = License.new
		assert !license.name
		assert !license.save
	end

	test "completed license with name does save" do
		license = License.new
		license.name = "Test License"
		assert license.name && license.name.present?
		assert license.save
	end
end
