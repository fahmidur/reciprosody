class ToolPublicationRelationship < ActiveRecord::Base
  belongs_to :tool
  belongs_to :publication
  attr_accessible :name
end
