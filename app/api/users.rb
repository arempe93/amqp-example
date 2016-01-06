module API
    class Users < Grape::API

		represent User, with: API::Entities::User
        represent Device, with: API::Entities::Device

		resource :users do

			desc 'Sign up a new user'
			params do
				requires :email, type: String
				requires :password, type: String
				requires :username, type: String
				optional :name, type: String

				group :device, type: Hash do
                    requires :uuid, type: String
                    requires :user_agent, type: String
                    optional :mobile, type: Boolean, default: false
                end
			end
			post do

				# create user
				user = User.new email: params[:email], password: params[:password], username: params[:username], name: params[:name]

				# create device
                device = Device.generate params[:device].to_hash.merge({ user: user })

                # get un-hashed auth token
                auth_token = device.token_hash

                begin

					# save user
					user.save!

                    # save new device
                    device.save!

				rescue ActiveRecord::ActiveRecordError => e

					unprocessable '422.1', e.message

                rescue => e

                    server_error! '500.1', e.message

                else

                    # present token and user
                    present :auth_token, auth_token
                    present :device, device
                end
			end

			desc 'Search users to chat with'
			params do
				optional :query, type: String, default: ''
				optional :auth_token, type: String
			end
			get do

				# normalize query
				query = params[:query].downcase

				# find users
				users = User.where 'lower(username) like :query or lower(name) like :query', query: "%#{query}%"

				# limit to 20 results
				users = users.limit 20

				# present results
				present :users, users
			end

			route_param :id do

				desc 'Get user information'
				params do
					optional :auth_token, type: String
				end
				get do

					# find user
					user = User.find_by id: params[:id]
					not_found! '404.1', 'User was not found' unless user

					present :user, user
				end

			end

            resource :check do

                desc 'Check username availability'
                params do
                    requires :username, type: String
                end
                get :username do

                    # find user
                    user = User.find_by username: params[:username]

                    # show availability
                    present :available, user.nil?
                end

            end
		end
	end
end
