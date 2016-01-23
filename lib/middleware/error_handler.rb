module Middleware
	class ErrorHandler < Grape::Middleware::Base

		def call!(env)

			# capture env
			@env = env

			begin

				# make api call
				@app.call @env

			rescue => e
				
				Rails.logger.error e.message
				Rails.logger.error e.backtrace.join("\n\t")

				# rescue from uncaught exceptions
				catch_error e
			end
		end

		private
		def catch_error(e)

			response = {
				response_code: 500,
				response_text: 'Internal Server Error',
				error_code: '500',
				error_text: e.message
			}

			[ 500, { 'Content-Type' => 'application/json' }, [ response.to_json ] ]
		end

	end
end