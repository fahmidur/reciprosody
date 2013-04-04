class Publication < ActiveRecord::Base
	attr_accessible :description, :keywords, :local, :name, :url, :authors, :citation, :pubdate, :venue

	has_many :corpora, :through => :publication_corpus_relationships
	has_many :publication_corpus_relationships, :dependent => :delete_all

	has_many :users, :through => :publication_memberships
	has_many :publication_memberships

	has_many :tools, :through => :tool_publication_relationships
	has_many :tool_publication_relationships, :dependent => :delete_all

	accepts_nested_attributes_for :publication_memberships, :users

	scope :publication_owner_of,	where(publication_memberships: {role: 'owner'})

	accepts_nested_attributes_for :publication_memberships, :users

	before_destroy :remove_dirs

	#---Validations------------------------
	validates :name, :presence => true
	validates :url, :url => true, :allow_blank => true
	#--------------------------------------

	#---Permissions-----
	# this should be called canBeEditedBy?
	# refactor later
	def canEdit?(user)
		return false unless user
		return true if user.super_key != nil
		return true if self.owners.include? user
		return false
	end
	#-------------------

	def ac_small_format
		"#{self.name}<#{self.id}>"
	end

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

	def keywords_array
		self.keywords.to_s.split(/[^\w,\-]+/)
	end
end
