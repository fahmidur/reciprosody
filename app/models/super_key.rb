class SuperKey < ActiveRecord::Base
	attr_accessible :user_id;
	belongs_to :user
	# attr_accessible :title, :body
end
