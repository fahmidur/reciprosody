class Tool < ActiveRecord::Base
  attr_accessible :author, :description, :keywords, :license, :local, :name, :programming_language, :url
end
