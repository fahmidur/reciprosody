# Relationship from Publication to Corpus
class PublicationCorpusRelationship < ActiveRecord::Base
  belongs_to :publication
  belongs_to :corpus
  attr_accessible :publication_id, :corpus_id, :name
end
