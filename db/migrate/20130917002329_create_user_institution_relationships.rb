class CreateUserInstitutionRelationships < ActiveRecord::Migration
  def change
    create_table :user_institution_relationships do |t|
      t.references :user
      t.references :institution

      t.timestamps
    end
    add_index :user_institution_relationships, :user_id
    add_index :user_institution_relationships, :institution_id
  end
end
