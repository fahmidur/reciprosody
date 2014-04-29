class SearchLogEntry < ActiveRecord::Base
  belongs_to :user
  belongs_to :resource_type

  attr_accessible :user_id, :resource_type_id, :input, :output
  paginates_per 100

  # Factory
  def self.make(user, resourceType, inString, outString)
  	resourceType = ResourceType.find_by_name(resourceType)
  	throw "Resource Type: #{resource_type_symbol} not found" unless resourceType

  	SearchLogEntry.create(
  		:user_id => user.id, 
  		:resource_type_id => resourceType.id,
  		:input => inString,
  		:output => outString
  		)

  end
end
