failed = []
File.open("programming_languages.txt", "r").each_line do |line|
	line.chomp!
	begin
		ProgrammingLanguage.create(:name => line)
	rescue
		failed << line
	end
end
puts "__FAILED TO BE ADDED__"
puts failed