class CreatePublications < ActiveRecord::Migration
  
  def change
    create_table :publications do |t|

      t.string :name
      
      t.text :keywords
      t.text :description
      t.text :authors

      t.string :url
      t.string :local

      t.timestamps
    end
    
  end
end
