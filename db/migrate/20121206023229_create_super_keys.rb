class CreateSuperKeys < ActiveRecord::Migration
  def change
    create_table :super_keys do |t|
      t.references :user

      t.timestamps
    end
    add_index :super_keys, :user_id
  end
end
