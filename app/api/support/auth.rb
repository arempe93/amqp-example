module API
	module Support
		module Auth

			def authenticate!

				begin

					device = Device.authenticate! params[:auth_token]

					[ device.user, device ]

				rescue => e

					unauthorized! '401.1', 'Token is missing or invalid'
				end
			end

		end
	end
end
