module ApplicationHelper
	def markdown(text)
		options = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
		::Redcarpet.new(text, *options).to_html
	end
	
	def snippet(html)
		doc = ::Nokogiri::HTML(html)
		first_paragraph = doc.at_css("p:first")
		return first_paragraph.inner_html if first_paragraph
		return ""
	end
end
