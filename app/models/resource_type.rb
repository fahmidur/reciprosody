class ResourceType < ActiveRecord::Base
	attr_accessible :name

	validates :name, :presence => true

	def self.fetch(q)
		q.downcase!
		return ResourceType.where(:name => q).first_or_create
	end
end
