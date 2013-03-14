class ToolMembership < ActiveRecord::Base
  belongs_to :tool
  belongs_to :publication
  attr_accessible :role, :tool_id, :publication_id
end
