class ResumableIncompleteUpload < ActiveRecord::Base
  belongs_to :user
  attr_accessible :filename, :formdata, :identifier, :url, :user_id
end
