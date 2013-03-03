module NavigationHelpers
	def path_to(page_name)
		case page_name
		when /the login page/
			'/users/sign_in'
		when /the home\s?page/
			'/'
		when /the logout page/
			'/users/sign_out'
		else
			begin
				page_name =~ /the (.+) page/
				self.send($1.split(/\s+/).push('path').join('_').to_sym)
			rescue
				raise	"Error finding mapping from \"#{page_name}\" to a path.\n"+
						"Add mapping in #{__FILE__}"
			end
		end
	end
end

World(NavigationHelpers)