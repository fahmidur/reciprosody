class Tool < ActiveRecord::Base
  include ActiveModel::Validations
  require 'uri'

  attr_accessible :authors, :description, :keywords, :license, :local, :name, :programming_language, :url
  paginates_per 3

  has_many :users, :through => :tool_memberships
  has_many :tool_memberships                                        
  accepts_nested_attributes_for :tool_memberships                       #delete *tool-user relationships

  has_many :corpora, :through => :tool_corpus_relationships
  has_many :tool_corpus_relationships, :dependent => :delete_all        #delete *tool-corpus relationships

  has_many :publications, :through => :tool_publication_relationships
  has_many :tool_publication_relationships, :dependent => :delete_all   #delete *tool-publication relationships

  scope :tool_owner_of, -> { where tool_memberships: {role: 'owner'} }
  scope :tool_approver_of, -> { where tool_memberships: {role: 'approver'} }
  scope :tool_member_of, -> { where tool_memberships: {role: 'member'} }

  before_destroy :remove_dirs

  #---Validations------------------------
  validates :name, :presence => true
  validates :url, :url => true, :allow_blank => true
  #--------------------------------------

  def to_timestring
    self.updated_at.strftime("%m-%d-%Y")
  end

  def to_short_description_string
    uri = URI.parse(url)
    host = uri.host

    if host == "github.com"
      if(url =~ /\/([^\/]+)\/?$/)
        return $1
      else
        return host
      end
    else
      return host
    end
  end

  def canEdit?(user)
  	return false unless user
  	return true if user.super_key != nil
  	return true if self.owners.include? user
  	return false
  end

  def owners
  	self.users.tool_owners.all
  end

  def reviewers
  	self.users.tool_reviewers.all
  end

  def members
  	self.users.tool_members.all
  end

  def keywords_array
    self.keywords.to_s.split(/[^\w,\-]+/)
  end

  def ac_small_format
    "#{self.name}<#{self.id}>"
  end

  def dir_path
    "tools/#{self.id}"
  end

  def remove_dirs
    FileUtils.rm_rf(dir_path) if Dir.exists?(dir_path)
  end

end
