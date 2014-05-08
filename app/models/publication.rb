class Publication < ActiveRecord::Base
	include UserActionable
	
	attr_accessible :description, :keywords, :local, :name, :url, :authors, :citation, :pubdate, :venue
	paginates_per 3

	has_many :corpora, :through => :publication_corpus_relationships
	has_many :publication_corpus_relationships, :dependent => :delete_all #delete *pub-corp relationships

	has_many :users, :through => :publication_memberships
	has_many :publication_memberships, :dependent => :delete_all		#delete *pub-user relationships

	has_many :tools, :through => :tool_publication_relationships
	has_many :tool_publication_relationships, :dependent => :delete_all #delete tool-*pub relationships

	has_many :user_actions, :as => :user_actionable

	accepts_nested_attributes_for :publication_memberships, :users

	scope :publication_owner_of,	-> { (where publication_memberships: {role: 'owner'}).order(:updated_at => :desc) 	}
	scope :publication_member_of,	-> { (where publication_memberships: {role: 'member'}).order(:updated_at => :desc) 	}
	scope :publication_approver_of,	-> { (where publication_memberships: {role: 'approver'}).order(:updated_at => :desc)}

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

	def self.valid_orders()
		["created_at", "updated_at", "name"]
	end

	# returns an array
	def self.wsearch(q)
		if(q !~ /^\%.+\%$/)
			q = "%#{q}%"
		end

		# let's not rely on implicit type changes
		chosen = 	where('name LIKE ? AND description LIKE ?', q, q).to_a
		chosen += 	where('name LIKE ?', q).to_a
		chosen +=	where('authors LIKE ?', q).to_a
		chosen +=	where('keywords LIKE ?', q).to_a
		chosen +=	where('description LIKE ?', q).to_a
		chosen +=	where('citation LIKE ?', q).to_a

		chosen.uniq!
		return chosen
	end

	def ac_small_format
		"#{self.name}<#{self.id}>"
	end

	def associated_users
		owners + reviewers + members
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
