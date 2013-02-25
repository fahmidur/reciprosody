class CreateSuperKeyRequests < ActiveRecord::Migration
  def change
    create_table :super_key_requests do |t|
      t.string :token
      t.references :user

      t.timestamps
    end
    add_index :super_key_requests, :user_id
  end
end
