class AddBioToUsers < ActiveRecord::Migration
  def change
    add_column :users, :bio_markdown, :text
    add_column :users, :bio_html, :text
  end
end
