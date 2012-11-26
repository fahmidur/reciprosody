class FillLicenses < ActiveRecord::Migration
  def change
  	licenses = []
	File.open("licenses.txt", "r").each do |line|
		licenses << License.new(:name => line)
	end
	License.import licenses
  end
end
