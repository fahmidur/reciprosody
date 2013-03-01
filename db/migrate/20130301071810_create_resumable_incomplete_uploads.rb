class CreateResumableIncompleteUploads < ActiveRecord::Migration
  def change
    create_table :resumable_incomplete_uploads do |t|
      t.string :filename
      t.string :identifier
      t.references :user
      t.string :url
      t.text :formdata

      t.timestamps
    end
    add_index :resumable_incomplete_uploads, :user_id
  end
end
