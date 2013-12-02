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
		text[0..chars] + "..."
	end
end
