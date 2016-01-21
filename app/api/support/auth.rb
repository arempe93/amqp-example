module API
	module Support
		module Auth

			def warden
				env['warden']
			end

			def authenticate!

				begin

					# get device for token
					device = Device.authenticate! params[:auth_token]

					# update last request time
					device.update_last_request!

					# update user information
					device.user.update_tracked_fields! warden.request

					# return user with requesting device
					[ device.user, device ]

				rescue => e

					unauthorized! '401.1', 'Token is missing or invalid'
				end
			end

		end
	end
end
