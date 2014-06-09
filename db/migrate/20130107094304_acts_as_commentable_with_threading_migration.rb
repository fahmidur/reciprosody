class ActsAsCommentableWithThreadingMigration < ActiveRecord::Migration
  def self.up
    create_table :comments, :force => true do |t|
      t.integer :commentable_id, :default => 0
      t.string :commentable_type, :default => ""
      t.string :title, :default => ""
      #t.text :body, :default => "" # SR: causes MySQL error - text/blob cannot have default in production
      t.text :body # SR: seems to fix the issue during migrate on production
      t.string :subject, :default => ""
      t.integer :user_id, :default => 0, :null => false
      t.integer :parent_id, :lft, :rgt
      t.timestamps
    end
    
    add_index :comments, :user_id
    add_index :comments, :commentable_id
  end
  
  def self.down
    drop_table :comments
  end
end
