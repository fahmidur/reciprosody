class Publication < ActiveRecord::Base
	attr_accessible :description, :keywords, :local, :name, :url, :authors

	has_many :corpora, :through => :publication_corpus_relationship
	has_many :users, :through => :publication_membership
end
