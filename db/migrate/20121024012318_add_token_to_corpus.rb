class AddTokenToCorpus < ActiveRecord::Migration
  def change
  	add_column :corpora, :utoken, :string
  end
end
