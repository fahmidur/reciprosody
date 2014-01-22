class FayeClientAugmenter
	def initialize
		Rails.logger.info "Faye ClientAuth initialization"
		@faye_password = Reciprosody2::FAYE_PASSWORD
		Rails.logger.info "AUTHENTICATION PASSWORD = #{@faye_password}"
	end

	def outgoing(message, callback)
		Rails.logger.info "**OUTGOING FAYE MESSAGE = #{message}"
		message['ext'] = message['ext'] || Hash.new
		message['ext']['password'] = @faye_password
		Rails.logger.info "**OUTGOING FAYE MESSAGE = #{message}"
		return callback.call(message)
	end
end