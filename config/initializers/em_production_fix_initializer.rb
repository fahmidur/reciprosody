class EmProductionFix
	@@logger = Logger.new("#{Rails.root}/log/custom.ProductionFix.log")

	def self.start
		@@logger.info "*** EMProductionFix ***"
		if defined?(PhusionPassenger)

			@@logger.info "*** EMProductionFix: PhusionPassenger Defined "
			PhusionPassenger.on_event(:starting_worker_process) do |forked|
				if forked && EM.reactor_running?
					EM.stop
				end
				Thread.new  { EM.run }
				die_gracefully
			end

		end
	end

	def self.die_gracefully
		Signal.trap("INT")	do
			@@logger.info "*** EMProductionFix: Stopping EM"
			EM.stop 
		end
		Signal.trap("TERM") do 
			@@logger.info "*** EMProductionFix: Stopping EM"
			EM.stop 
		end
	end
end

EmProductionFix.start