class Tool < ActiveRecord::Base
  include ActiveModel::Validations

  attr_accessible :authors, :description, :keywords, :license, :local, :name, :programming_language, :url

  has_many :users, :through => :tool_memberships
  has_many :tool_memberships
  accepts_nested_attributes_for :tool_memberships

  has_many :corpora, :through => :tool_corpus_relationships
  has_many :tool_corpus_relationships, :dependent => :delete_all

  has_many :publications, :through => :tool_publication_relationships
  has_many :tool_publication_relationships, :dependent => :delete_all

  scope :tool_owner_of, where(tool_memberships: {role: 'owner'})

  #---Validations------------------------
  validates :name, :presence => true
  validates :url, :url => true, :allow_blank => true
  #--------------------------------------

  def to_timestring
    self.updated_at.strftime("%m-%d-%Y")
  end

  def to_short_description_string
    if(url =~ /\/([^\/]+)\/?$/)
      return $1
    else
      return url
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

end
