module Citable
	def citation_format(style = 'apa')
		begin
			processor = CiteProc::Processor.new :style => style, :format => 'html'
			citeproc = BibTeX.parse("#{self.citation}").to_citeproc
			processor.import(citeproc)
			key = processor.items.first[0]
			return processor.render(:bibliography, :id => key).first
		rescue
			return nil
		end
	end
end