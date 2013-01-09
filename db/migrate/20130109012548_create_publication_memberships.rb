class CreatePublicationMemberships < ActiveRecord::Migration
  def change
    create_table :publication_memberships do |t|
      t.string :role
      t.references :user
      t.references :publication

      t.timestamps
    end
    add_index :publication_memberships, :user_id
    add_index :publication_memberships, :publication_id
  end
end
