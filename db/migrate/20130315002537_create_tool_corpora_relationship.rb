class CreateToolCorporaRelationship < ActiveRecord::Migration
  def change
    create_table :tool_corpora_relationship do |t|
      t.references :tool
      t.references :corpus
      t.string :name

      t.timestamps
    end
    add_index :tool_corpora_relationship, :tool_id
    add_index :tool_corpora_relationship, :corpus_id
  end
end
