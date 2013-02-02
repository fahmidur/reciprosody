class CreatePublicationKeywords < ActiveRecord::Migration
  def change
    create_table :publication_keywords do |t|
      t.string :name
    end
  end
end
