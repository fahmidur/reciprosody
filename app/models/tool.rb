class Tool < ActiveRecord::Base
  attr_accessible :authors, :description, :keywords, :license, :local, :name, :programming_language, :url
end
