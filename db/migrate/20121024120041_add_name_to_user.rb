class AddNameToUser < ActiveRecord::Migration

  def change
  	add_column :users, :name, :string, :limit => 100
  end
  
end
