class ToolMembership < ActiveRecord::Base
  belongs_to :tool
  belongs_to :user
  attr_accessible :role, :tool_id, :user_id

  def self.roles
  	['owner', 'reviewer', 'member']
  end
end
