class UserActionType < ActiveRecord::Base
	attr_accessible :name, :desc

	validates :name, :presence => true

	def self.fetch(q)
		q.downcase!
		return UserActionType.where(:name => q).first_or_create
	end
end
