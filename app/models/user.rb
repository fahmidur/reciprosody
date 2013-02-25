class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable, :confirmable,
	# :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	 :recoverable, :rememberable, :trackable, :validatable, :confirmable

	# Setup accessible (or protected) attributes for your model
	attr_accessible :email, :password, :password_confirmation, :remember_me, :name

	has_many :corpora, :through => :memberships

	has_many :publications, :through => :publication_memberships

	has_many :memberships #to corpora
	has_many :publication_memberships
	
	has_one :super_key

	scope :owners,		where(:memberships => {role: 'owner'})
	scope :approvers,	where(:memberships => {role: 'approver'})
	scope :members,		where(:memberships => {role: 'member'})


	scope :publication_owners,			where(:publication_memberships => {role: 'owner'})
	scope :publication_reviewers,		where(:publication_memberships => {role: 'reviewer'})
	scope :publication_members,			where(:publication_memberships => {role: 'member'})

	# get all super key holders
	def self.supers
		User.joins(:super_key)
	end


	#--Memberships to Publications--
	def publication_owner_of
		self.publications.publication_owner_of
	end

	#--Memberships to Corpora--

	def owner_of
		self.corpora.owner_of.all
	end
	
	def approver_of
		self.corpora.approver_of.all
	end
	
	def member_of
		self.corpora.member_of.all
	end
	
	def email_format
		"#{self.name}<#{self.email}>"
	end

end
