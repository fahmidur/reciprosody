class User < ActiveRecord::Base
	# Include default devise modules. Others available are:
	# :token_authenticatable, :confirmable,
	# :lockable, :timeoutable and :omniauthable
	devise :database_authenticatable, :registerable,
	 :recoverable, :rememberable, :trackable, :validatable, :confirmable

	# Setup accessible (or protected) attributes for your model
	attr_accessible :email, :password, :password_confirmation, :remember_me, :name, :avatar, :gravatar_email, :bio_markdown, :bio_html

	validates_format_of :gravatar_email, :with => Devise.email_regexp, :allow_blank => true

	has_attached_file :avatar, :styles => { :medium => "200x200>", :thumb => "100x100>" }, 
		:default_url => ActionController::Base.helpers.asset_path('missing_:style.png')

	#----------------------------------------

	acts_as_messageable :table_name => "messages",
						:required => :body,
						:class_name => "ActsAsMessageable::Message",
						:dependent => :destroy,
						:group_messages => true

	#----------------------------------------

	has_many :actions, :foreign_key => 'user_id', :class_name => 'UserAction'

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

	def self.markdown(text)
		options = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
		::Redcarpet.new(text, *options).to_html
	end
	
	def bio=(md)
		md.gsub!(/\<\s*\/*\s*script\s*\>/, '');
		self.bio_markdown = md
		self.bio_html = User.markdown(md)
	end

	def clear_avatars_cache
		FileUtils.rm_rf(self.avatars_folder)
	end

	def avatars_folder
		return Rails.root + "avatars" + self.id.to_s
	end

	def self.wsearch(q, limit=10)
		if(q !~ /^\%.+\%$/)
			q = "%#{q}%"
		end
		q = "%#{q}%"
		result =  User.where("email = ?", q).to_a
		result += User.where("email LIKE ?", q).to_a
		result += User.where("name LIKE ?", q).to_a
		result += User.includes(:institutions).where("institutions.name LIKE ?", q).references(:institutions).to_a
		result = result.uniq.first(limit)
		return result
	end

	def insts
		UserInstitutionRelationship.where(:user_id => self.id).map{|rel| Institution.find_by_id(rel.institution_id)}
	end

	def insts_string
		insts.map{|inst| inst.name }.join(", ")
	end

	##
	# setProp allows you to set
	# a key-value pair to act
	# as a property for the user
	#
	# if no value is given
	# that property is simply
	# removed
	#
	# this pertains the user_properties table
	# or the UserProperty model
	def setProp(name, value=nil)
		prop = self.user_properties.find_by_name(name)
		if(prop)
			prop.destroy()
		end

		if value != nil
			self.user_properties.create(:name => name, :value => value)
		end
	end

	##
	# getProp allows you to get
	# a property for a certain user
	#
	# if a name is not supplied
	# it returns all properties 
	# for the user
	#
	# this pertains the user_properties table
	# or the UserProperty model
	def getProp(name = nil)
		if(name == nil)
			return self.user_properties
		end
		prop = self.user_properties.find_by_name(name)
		return prop.value if prop
		return nil
	end

	# messages a group of users
	# "this user is shouting at a set
	# of users"
	def shout(users, topic, body, fayeproc = nil)
		users -= [self] if users

		if !users || users.size <= 0
			logger.info "***USER@SHOUT ! users empty"
			return
		end
		
		users.each do |u|
			message = self.send_message(u, {:topic => topic, :body => body})
			fayeproc.call(message) if fayeproc
		end
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
	def associated_tools
		tool_owner_of + tool_reviewer_of + tool_member_of
	end

	def tool_owner_of
		self.tools.tool_owner_of
	end

	def tool_reviewer_of
		self.tools.tool_reviewer_of
	end

	def tool_member_of
		self.tools.tool_member_of
	end

	#--Memberships to Publications--
	def associated_publications
		publication_owner_of + publication_reviewer_of + publication_member_of
	end

	def publication_owner_of
		self.publications.publication_owner_of
	end

	def publication_reviewer_of
		self.publications.publication_reviewer_of
	end
	
	def publication_member_of
		self.publications.publication_member_of
	end
	

	#--Memberships to Corpora--
	def associated_corpora
		self.owner_of + self.approver_of + self.member_of
	end

	def owner_of
		self.corpora.owner_of
	end
	
	def approver_of
		self.corpora.approver_of
	end
	
	def member_of
		self.corpora.member_of
	end
	
	def email_format
		"#{self.name}<#{self.email}>"
	end

	def gravatar_url(type, size=200)
		gravatar_email = self.gravatar_email || self.email
		gravatar_id = Digest::MD5.hexdigest(gravatar_email.downcase)
		return "http://gravatar.com/avatar/#{gravatar_id}.#{type}?s=#{size}"
	end

	def gravatar_url_typeless(size=200)
		gravatar_email = self.gravatar_email || self.email
		gravatar_id = Digest::MD5.hexdigest(gravatar_email.downcase)
		return "http://gravatar.com/avatar/#{gravatar_id}?s=#{size}"
	end
end
