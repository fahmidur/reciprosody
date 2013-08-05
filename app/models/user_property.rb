class UserProperty < ActiveRecord::Base
  belongs_to :user
  attr_accessible :name, :value

  def self.valid_properties
  	["inbox_block_emails"]
  end
end
