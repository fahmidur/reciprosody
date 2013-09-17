class UserInstitutionRelationship < ActiveRecord::Base
  belongs_to :user
  belongs_to :institution
  attr_accessible :user_id, :institution_id
end
