class CreateToolPublicationRelationships < ActiveRecord::Migration
  def change
    create_table :tool_publication_relationships do |t|
      t.references :tool
      t.references :publication
      t.string :name

      t.timestamps
    end
    add_index :tool_publication_relationships, :tool_id
    add_index :tool_publication_relationships, :publication_id
  end
end
