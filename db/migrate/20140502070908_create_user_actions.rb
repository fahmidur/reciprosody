class CreateUserActions < ActiveRecord::Migration
  def change
    create_table :user_actions do |t|
    	t.references :user
    	t.references :user_action_type
    	t.references :user_actionable, :polymorphic => true

    	t.string :ip_address #request.remote_ip
    	t.float :lat #login actions, download actions, etc
    	t.float :lon

    	t.string :message

    	t.timestamps
    end
  end
end
