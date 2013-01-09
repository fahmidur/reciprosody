class CreatePublicationCorporaRelationship < ActiveRecord::Migration
  def change
    create_table :publication_corpora_relationship do |t|
      t.references :publication
      t.references :corpus
      t.string :name

      t.timestamps
    end
    add_index :publication_corpora_relationship, :publication_id
    add_index :publication_corpora_relationship, :corpus_id
  end
end
