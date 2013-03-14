class ToolMembership < ActiveRecord::Base
  belongs_to :tool
  belongs_to :publication
  attr_accessible :role
end
