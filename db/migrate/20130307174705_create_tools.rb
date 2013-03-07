class CreateTools < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.string :name
      t.string :author
      t.string :programming_language
      t.string :license
      t.text :description
      t.text :keywords
      t.string :url
      t.string :local

      t.timestamps
    end
  end
end
