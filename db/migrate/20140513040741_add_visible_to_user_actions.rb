class AddVisibleToUserActions < ActiveRecord::Migration
  def change
    add_column :user_actions, :visible, :boolean, :default => true
  end
end
