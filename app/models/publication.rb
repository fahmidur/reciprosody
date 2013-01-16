class Publication < ActiveRecord::Base
	attr_accessible :description, :keywords, :local, :name, :url, :authors, :citation

	has_many :corpora, :through => :publication_corpus_relationship
	has_many :users, :through => :publication_memberships

	has_many :publication_memberships

	accepts_nested_attributes_for :publication_memberships, :users

	scope :publication_owner_of,	where(publication_memberships: {role: 'owner'})

	accepts_nested_attributes_for :publication_memberships, :users

	before_destroy :remove_dirs

	def owners
		self.users.publication_owners.all
	end

	def reviewers
		self.users.publication_reviewers.all
	end

	def members
		self.users.publication_members.all
	end

	def dir_path
		"publications/#{self.id}"
	end

	def remove_dirs
		FileUtils.rm_rf(dir_path) if Dir.exists? dir_path
	end
end
