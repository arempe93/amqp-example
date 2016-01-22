module API
	class Auth < Grape::API

		represent Device, with: API::Entities::Device

		resource :tokens do

			desc 'Authenticate a new device'
			params do

				requires :username, type: String
				requires :password, type: String

				group :device, type: Hash do
					requires :uuid, type: String
					requires :user_agent, type: String
					optional :mobile, type: Boolean, default: false
				end
			end
			post do

				# find user
				user = User.find_by username: params[:username]
				not_found! '404.1', 'User was not found' unless user

				# authenticate user
				unauthorized! '401.1' unless user.valid_password?(params[:password])

				# create device
				device = Device.generate params[:device].to_hash.merge({ user: user })

				# validate device
				validate! device, '422.1'

				# get un-hashed auth token
				auth_token = device.token_hash

				begin

					# save new device
					device.save!

				rescue => e

					server_error! '500.1', e.message

				else

					# present token and user
					present :auth_token, auth_token
					present :device, device
				end
			end

		end
	end
end
