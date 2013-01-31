class AddToPublicationsVenueYear < ActiveRecord::Migration
  def change
  	add_column :publications, :venue, :text
  	add_column :publications, :pubdate, :datetime
  end
end
