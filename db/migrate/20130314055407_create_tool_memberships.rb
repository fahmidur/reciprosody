class CreateToolMemberships < ActiveRecord::Migration
  def change
    create_table :tool_memberships do |t|
      t.references :tool
      t.references :user
      t.string :role

      t.timestamps
    end
    add_index :tool_memberships, :tool_id
    add_index :tool_memberships, :user_id
  end
end
