class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable, :confirmable,
	# :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	 :recoverable, :rememberable, :trackable, :validatable, :confirmable

	# Setup accessible (or protected) attributes for your model
	attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :avatar

	has_attached_file :avatar, :styles => { :medium => "200x200>", :thumb => "100x100>" }, 
		:default_url => ActionController::Base.helpers.asset_path('missing_:style.png')

	#----------------------------------------

	acts_as_messageable :table_name => "messages",
						:required => :body,
						:class_name => "ActsAsMessageable::Message",
						:dependent => :destroy,
						:group_messages => true


	#----------------------------------------

	

	has_many :corpora, :through => :memberships

	has_many :publications, :through => :publication_memberships

	has_many :tools, :through => :tool_memberships

	has_many :institutions, :through => :user_institution_relationships


	has_many :memberships, :dependent => :delete_all					# delete *user-corpus relationships (memberships)
	has_many :publication_memberships, :dependent => :delete_all		# delete *user-pub relationships	(memberships)
	has_many :tool_memberships, :dependent => :delete_all				# delete *user-tool relationships	(meberships)
	has_many :user_institution_relationships, :dependent => :delete_all #delete *user-insutution relationships

	has_many :user_properties

	has_one :super_key

	scope :owners,		-> { where :memberships => {role: 'owner'} }
	scope :approvers,	-> { where :memberships => {role: 'approver'} }
	scope :members,		-> { where :memberships => {role: 'member'} }


	scope :publication_owners, -> { where :publication_memberships => {role: 'owner'} }
	scope :publication_reviewers, -> { where :publication_memberships => {role: 'reviewer'} }
	scope :publication_members, -> { where :publication_memberships => {role: 'member'} }

	scope :tool_owners, -> { where :tool_memberships => {:role => 'owner'} }
	scope :tool_reviewers, -> { where :tool_memberships => {:role => 'reviewer'} }
	scope :tool_members, -> { where :tool_memberships => {:role => 'member'} }

	def insts
		UserInstitutionRelationship.where(:user_id => self.id).map{|rel| Institution.find_by_id(rel.institution_id)}
	end

	def insts_string
		insts.map{|inst| inst.name }.join(", ")
	end

	def setProp(name, value)
		prop = self.user_properties.find_by_name(name)
		if(prop)
			prop.destroy()
		end

		if value != nil
			self.user_properties.create(:name => name, :value => value)
		end
	end

	# messages a group of users
	# "this user is shouting at a set
	# of users"
	def shout(users, topic, body, fayeproc)
		users -= [self] if users

		if !users || users.size <= 0
			logger.info "***USER@SHOUT ! users empty"
			return
		end

		unless fayeproc
			logger.info "***USER@SHOUT ! Faye client not found"
			return
		end

		users.each do |u|
			message = self.send_message(u, {:topic => topic, :body => body})
			fayeproc.call(message)
		end
	end

	def getProp(name = nil)
		if(name == nil)
			return self.user_properties
		end
		prop = self.user_properties.find_by_name(name)
		return prop.value if prop
		return nil
	end


	def resumables
		ResumableIncompleteUpload.where(:user_id => self.id).order("updated_at DESC")
	end

	def commit_header
		"User Name: #{self.name}<br/>User Email: #{self.email}<br/>\n"
	end

	# get all super key holders
	def self.supers
		User.joins(:super_key)
	end

	#--Memberships to Tools--
	def tool_owner_of
		self.tools.tool_owner_of
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

	def gravatar_url(type)
		gravatar_id = Digest::MD5.hexdigest(self.email.downcase)
		return "http://gravatar.com/avatar/#{gravatar_id}.#{type}?s=200"
	end

end
