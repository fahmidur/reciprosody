class PublicationCorpusRelationship < ActiveRecord::Base
  belongs_to :publication
  belongs_to :corpus
  attr_accessible :name
end
