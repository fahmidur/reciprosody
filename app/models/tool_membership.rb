class ToolMembership < ActiveRecord::Base
  belongs_to :tool
  belongs_to :user
  attr_accessible :role, :tool_id, :user_id

  def self.roles
  	['owner', 'reviewer', 'member']
  end

  def self.clean
  	ToolMembership.all.each do |mem|
  		user = User.find_by_id(mem.user_id)
  		tool = Tool.find_by_id(mem.tool_id)
  		unless user && tool
  			mem.destroy
  		end
  	end
  end

end
