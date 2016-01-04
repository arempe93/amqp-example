module API
	class Subscriptions < Grape::API

		represent Feed, with: API::Entities::Feed

		resource :feeds do
			route_param :id do

				desc 'Subscribe to a feed'
				params do
					optional :auth_token, type: String
				end
				post :subscribe do

					# find feed
					feed = Feed.find_by id: params[:id]
					not_found! '404.1', 'Feed was not found' unless feed

					# subscribe
					@user.subscribe! feed

					# show updated feed
					present :feed, feed
				end

				desc 'Unsubscribe from a feed'
				params do
					optional :auth_token, type: String
				end
				delete :unsubscribe do

					# find feed
					feed = Feed.find_by id: params[:id]
					not_found! '404.1', 'Feed was not found' unless feed

					begin

						# subscribe
						@user.unsubscribe! feed

					rescue ActiveRecord::RecordNotFound => e

						# user was not subscribed
						not_found! '404.2', e.message
					end

					# show updated feed
					present :feed, feed
				end

			end
		end
	end
end
