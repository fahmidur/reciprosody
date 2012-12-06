module ApplicationHelper
	def markdown(text)
		options = [:hard_wrap, :filter_html, :autolink, :no_intraemphasis, :fenced_code, :gh_blockcode]
		::Redcarpet.new(text, *options).to_html
	end
	
	def snippet(html)
		doc = ::Nokogiri::HTML(html)
		doc.at_css("p:first").inner_html
	end
end
