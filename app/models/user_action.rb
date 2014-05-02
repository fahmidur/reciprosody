class UserAction < ActiveRecord::Base
	belongs_to :user_actionable, :polymorphic => true
	belongs_to :user
end
