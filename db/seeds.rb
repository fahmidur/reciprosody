# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

# Populate Languages from the file langs.txt

seedFilesByClass = {
	Language => 'langs.txt',
	License => 'licenses.txt',
	ProgrammingLanguage => 'programming_languages.txt'
}

seedFilesByClass.each do |klass, filename|
	break if Rails.env == 'test'
	count = 0
	puts "* SEEDING CLASS #{klass} FROM #{filename}"
	File.open(seedFilesByClass[klass]).each_line do |name|
		name.chomp!
		next if klass.find_by_name(name)
		klass.create(:name => name)
		count += 1
		puts "\t|#{name}|"
	end
	puts "* #{count} #{klass} INSTANCES MADE"
	puts
end
puts

# STATIC SEEDS

puts "* SEEDING ResourceTypes Table"
resourceTypes = ['user', 'corpus', 'publication', 'tool']
resourceTypes.each do |type|
	ResourceType.fetch(type)
	puts "\t|#{type}|"
end
puts "* #{resourceTypes.length} ResourceTypes Seeded"


puts "* SEEDING ActionType Table"
userActionTypes = [
	'download',
	'upload',
	'file_rename',
	'registered_view',
	'public_view',
	'follow_link',
	'update'
	];
userActionTypes.each do |type|
	UserActionType.fetch(type)
	puts "\t|#{type}|"
end
puts "* #{userActionTypes.length} ActionTypes Seeded"