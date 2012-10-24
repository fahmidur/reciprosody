class Corpus < ActiveRecord::Base
  attr_accessible :description, :language, :name, :upload
  before_destroy :remove_dirs
  
  validates :name, :presence => true
  validates :language, :presence => true
  #validates :description, :presence => true
  
  attr_accessor :upload_file
  
  def upload=(upload_file)
  	@upload_file = upload_file
  end
  
  def remove_dirs
  	FileUtils.rm_rf("corpora.files/#{self.utoken}/");
  	FileUtils.rm_rf("corpora.archives/#{self.utoken}/");
  end
  
end
