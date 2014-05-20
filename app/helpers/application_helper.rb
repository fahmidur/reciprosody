module ApplicationHelper
	def markdown(text)
		options = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
		::Redcarpet.new(text, *options).to_html
	end

	def mainUrl
		"http://#{Rails.application.config.action_mailer.default_url_options[:host]}"
	end
	
	def snippet(html)
		doc = ::Nokogiri::HTML(html)
		first_paragraph = doc.at_css("p:first")
		return first_paragraph.inner_html if first_paragraph
		return ""
	end

	def text_snippet(text, chars)
		return text[0..chars] + "..." if text
		return "..."
	end

	def html_from_citation(text, style)
		begin
			text = "" if !text || text.blank?
			b = BibTeX.parse text
			return CiteProc.process b.to_citeproc, :style => style, :format => :html
		rescue => exception
			logger.info "*******ERROR*****\n\n#{exception}\n\n"
			return ""
		end
	end
end
