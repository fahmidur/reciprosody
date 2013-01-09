class AddCitationToPublication < ActiveRecord::Migration
  def change
  	add_column :publications, :citation, :text
  end
end
