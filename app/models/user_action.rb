class UserAction < ActiveRecord::Base
	belongs_to :user_actionable, :polymorphic => true
	belongs_to :user
	belongs_to :user_action_type

	attr_accessible :version

	paginates_per 7
end
