require 'faye'
require 'faye/websocket'
require 'yaml'

# 
# Apparently this is necessary to avoid the
# socket Upgrade header missing error in Chrome
# 
# Thank you Faye Team (once again) for 
# the adventure of finding this in some obscure
# thread.
Faye::WebSocket.load_adapter('thin')

SECRETS_FILE = 'static_secrets.yaml'
# Major Security Fix 01-21-2014 (SFR)
# All pubs now authenticated
class ServerAuth
	def initialize
		puts "Faye ServerAuth Initializing..."
		static_secrets = YAML::load(File.read(SECRETS_FILE))
		@faye_password = static_secrets[:faye_password]
		puts "AUTHENTICATION PASSWORD = #{@faye_password}"
	end

	def incoming(message, callback)
		# p message
		unless(message['channel'] =~ /^\/meta/)
			password = message['ext'] && message['ext']['password']
			# puts "PASSWORD = |#{@faye_password}|\t|#{password}|"
			if(password != @faye_password)
				message['error'] = '403::Password required'
			end
		end
		# message[:error] = '403::Password required'
		return callback.call(message)
	end

	def outgoing(message, callback)
		if(message['ext'])
			message['ext'].delete('password')
		end
		return callback.call(message)
	end
end

server = Faye::RackAdapter.new(:mount => '/faye', :timeout => 25);
server.add_extension(ServerAuth.new)
# server.listen(9292); # Apparently Deprecated by Faye 1.x since the Update 01-28-2014
run server
