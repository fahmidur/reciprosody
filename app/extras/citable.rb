module Citable
	def citation_format(style = 'apa')
		begin
			processor = CiteProc::Processor.new :style => style, :format => 'html'
			citeproc = BibTeX.parse("#{self.citation}").to_citeproc
			processor.import(citeproc)
			key = processor.items.first[0]
			return processor.render(:bibliography, :id => key).first
		rescue
			# return "<div class='invalid-format-sticker'>Invalid Format</div>"
			return nil
		end
	end

	def citation_formats(styles)
		formats = {}
		tmp = nil
		styles.each do |abbr, style|
			tmp = self.citation_format(style)
			formats[abbr] = tmp if tmp
		end
		return formats
	end
end