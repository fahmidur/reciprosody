class ExpandCorpus < ActiveRecord::Migration
  def change
  	add_column :corpora, :duration, :integer
  	add_column :corpora, :num_speakers, :integer
  	add_column :corpora, :speaker_desc, :string
  	add_column :corpora, :genre, :string
  	add_column :corpora, :annotation, :string
  	add_column :corpora, :license, :string
  	add_column :corpora, :citation, :text
  end
end
