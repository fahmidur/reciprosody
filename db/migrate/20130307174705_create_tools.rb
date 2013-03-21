class CreateTools < ActiveRecord::Migration
  def change
    create_table :tools do |t|
      t.string :name
      t.string :programming_language
      t.string :license
      t.string :url
      t.text :authors
      t.text :description
      t.text :keywords
      
      t.string :local
      t.timestamps
    end
  end
end
