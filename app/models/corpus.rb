class Corpus < ActiveRecord::Base
  attr_accessible :description, :language, :name
  validates :name, :presence => true
  validates :language, :presence => true
  #validates :description, :presence => true
end
