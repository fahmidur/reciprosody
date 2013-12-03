class FillLicenses < ActiveRecord::Migration
  def change
  	licenses = []
	File.open("licenses.txt", "r").each do |line|
		line.chomp!
		# licenses << License.new(:name => line)
		License.create(:name => line)
	end
	# License.import licenses
  end
end
