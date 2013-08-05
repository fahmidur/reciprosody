class CreateUserProperties < ActiveRecord::Migration
  def change
    create_table :user_properties do |t|
      t.references :user
      t.string :name
      t.string :value

      t.timestamps
    end
    add_index :user_properties, :user_id
  end
end
