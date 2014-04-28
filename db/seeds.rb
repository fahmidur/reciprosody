# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Populate Languages from the file langs.txt

seedFiles = {
	:languages => 'langs.txt',
}



if seedFiles[:languages]
	count = 0
	puts "* SEEDING LANGAUGES TABLES FROM FILE: #{seedFiles[:languages]}"
	File.open(seedFiles[:languages], 'r').each_line do |lang|
		lang.chomp!
		next if Language.find_by_name(lang)
		Language.create(:name => lang)
		puts "\t|#{lang}|"
		count += 1
	end
	puts "* #{count} LANGUAGES SEEDED"
end