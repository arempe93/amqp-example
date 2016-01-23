module Middleware
	class APILogger < Grape::Middleware::Base
		
		def before

			Rails.logger.info "REQUEST METHOD:\t#{env['REQUEST_METHOD']}"
			Rails.logger.info "REQUEST PATH:\t#{env['REQUEST_PATH']}"
			Rails.logger.info "QUERY STRING:\t#{env['QUERY_STRING']}"
			Rails.logger.info "POST PARAMS:\t#{env['rack.request.form_hash']}"
		end

	end
end