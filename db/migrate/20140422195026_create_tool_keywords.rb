class CreateToolKeywords < ActiveRecord::Migration
  def change
    create_table :tool_keywords do |t|
      t.string :name
    end
  end
end
