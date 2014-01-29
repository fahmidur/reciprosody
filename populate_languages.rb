File.open("langs.txt", "r").each do |line|
	line.chomp!
	Language.create(:name => line) unless Language.find_by_name(line)
end