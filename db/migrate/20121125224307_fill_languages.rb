class FillLanguages < ActiveRecord::Migration
  def change
  	langs = []
	File.open("langs.txt", "r").each do |line|
		langs << Language.new(:name => line)
	end
	Language.import langs
  end
end
