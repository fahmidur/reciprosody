class CreateUserActionTypes < ActiveRecord::Migration
  def change
    create_table :user_action_types do |t|
      t.string :name
      t.text :desc
    end
  end
end
