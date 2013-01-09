class Corpus < ActiveRecord::Base
	acts_as_commentable

	attr_accessible :description, :language, :name, :upload, :duration, :num_speakers, :speaker_desc, :genre, :annotation, :license, :citation, :hours, :minutes, :seconds

	has_many :users, :through => :memberships
	has_many :memberships, :dependent => :delete_all #cascading delete

	has_many :publications, :through => :publication_corpus_relationships

	has_many :comments, :as => :commentable, :order => 'updated_at DESC'

	before_destroy :remove_dirs

	before_validation :set_duration

	validates :name, :presence => true
	validates :language, :presence => true
	validates :num_speakers, :inclusion => 1..9999
	validates :duration, :inclusion => {:in => 1..86399, :message => "must be at least 1 second and less than 24 hours"}, :if => :times_in_correct_format

	attr_accessor :upload_file, :hours, :minutes, :seconds

	after_find :set_times

	#---Static Methods  -----------------------------------
	def self.corpora_folder
		"corpora"
	end

	def self.tmp_subFolder
		"tmp"
	end
	
	def self.archives_subFolder
		"archives"
	end
	
	def self.head_subFolder
		"head"
	end
	
	def self.svn_subFolder
		"svn"
	end
	
	#------------------------------------------------------
	# Non-Static Helpers
	def home_path
		Corpus.corpora_folder  + "/" + self.utoken
	end
	
	def archives_path
		home_path + "/" + Corpus.archives_subFolder
	end
	
	def tmp_path
		home_path + "/" + Corpus.tmp_subFolder
	end
	
	def svn_path
		home_path + "/" + Corpus.svn_subFolder
	end
	
	def head_path
		home_path + "/" + Corpus.head_subFolder
	end
	
	def svn_file_url
		"file://#{Rails.root}/#{self.svn_path}"
	end
	
	#-------------------------------------------------------

	#------------------Rights-------------------------------
	# Not exactly the same as memberships
	#-------------------------------------------------------
	def canEdit?(user)
		return true if self.owners.include? user
		return true if user.super_key != nil
		return false
	end
	
	#-------------------memberships-------------------------
	accepts_nested_attributes_for :memberships, :users

	scope :owner_of,	where(memberships: {role: 'owner'})
	scope :approver_of,	where(memberships: {role: 'approver'})
	scope :member_of, 	where(memberships: {role: 'member'})


	def owners
		self.users.owners.all
	end

	def approvers
		self.users.approvers.all
	end

	def members
		self.users.members.all
	end
	#--------------------------------------------------------

	#--Attribute_writer for @upload_file
	def upload=(upload_file)
		@upload_file = upload_file
	end

	#--Removes associated directories
	def remove_dirs
		FileUtils.rm_rf("#{Corpus.corpora_folder}/#{self.utoken}");
	end
	
	def create_dirs
		return if Dir.exists? self.home_path

		Dir.mkdir self.home_path 
		sub_dir = []
		
		sub_dir << self.archives_path;
		sub_dir << self.tmp_path;
		sub_dir << self.head_path;
		sub_dir << self.svn_path;
	
		sub_dir.each do |d|
			Dir.mkdir d unless Dir.exists? d
		end
		
	end

	#--Returns human-readable duration
	def human_duration
		Time.at(self.duration).gmtime.strftime('%R:%S')
	end

	#--Times format validator function--
	def times_in_correct_format
		hours   = if @hours.nil?    then 0 else @hours.to_i end
		minutes = if @minutes.nil?  then 0 else @minutes.to_i end
		seconds = if @seconds.nil?  then 0 else @seconds.to_i end

		if hours < 0 || hours > 23 then
			errors.add(:hours, "Must be between 0 and 23")
			return false
		end
		if minutes < 0 || minutes > 59 then
			errors.add(:minutes, "must be between 0 and 59")
			return false
		end
		if seconds < 0 || seconds > 59 then
			errors.add(:seconds, "must be between 0 and 59")
			return false
		end
		return true
	end

	#Sets hours, minutes, seconds
	def set_times
		seconds = self.duration
		@hours    = seconds/3600; seconds %= 3600
		@minutes  = seconds/60; seconds %= 60
		@seconds  = seconds
	end
	#--Sets duration from virtual attributes--
	def set_duration
		@hours    = 0 if @hours.nil?
		@minutes  = 0 if @minutes.nil?
		@seconds  = 0 if @seconds.nil?
		self.duration = @hours.to_i()*3600 + @minutes.to_i()*60 + @seconds.to_i()
	end


end
