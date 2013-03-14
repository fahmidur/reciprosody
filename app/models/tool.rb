class Tool < ActiveRecord::Base
  attr_accessible :authors, :description, :keywords, :license, :local, :name, :programming_language, :url

  has_many :users, :through => :tool_memberships
  has_many :tool_memberships
  accepts_nested_attributes_for :tool_memberships

  scope :tool_owner_of, where(tool_memberships: {role: 'owner'})

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

end
