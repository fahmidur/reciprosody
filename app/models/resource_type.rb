class ResourceType < ActiveRecord::Base
	attr_accessible :name

	def self.fetch(q)
		q.downcase!
		return ResourceType.where(:name => q).first_or_create
	end
end
