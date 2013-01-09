class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable, :confirmable,
	# :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	 :recoverable, :rememberable, :trackable, :validatable, :confirmable

	# Setup accessible (or protected) attributes for your model
	attr_accessible :email, :password, :password_confirmation, :remember_me, :name

	has_many :corpora, :through => :memberships
	has_many :memberships
	
	has_one :super_key

	scope :owners,		where(:memberships => {role: 'owner'})
	scope :approvers,	where(:memberships => {role: 'approver'})
	scope :members,		where(:memberships => {role: 'member'})


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
