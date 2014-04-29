class CreateSearchLogEntries < ActiveRecord::Migration
  def change
    create_table :search_log_entries do |t|
      t.references :user, index: true
      t.references :resource_type, index: true
      t.string :input
      t.text :output

      t.timestamps
    end
  end
end
