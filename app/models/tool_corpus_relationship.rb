class ToolCorpusRelationship < ActiveRecord::Base
  belongs_to :tool
  belongs_to :corpus
  attr_accessible :name, :tool_id, :corpus_id
end
