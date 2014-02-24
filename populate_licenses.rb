File.open("licenses.txt", "r").each do |line|
	line.chomp!
	License.create(:name => line) unless License.find_by_name(line)
end