module API
	class Feeds < Grape::API

		represent Feed, with: API::Entities::Feed
		represent Message, with: API::Entities::Message

		resource :feeds do

			desc 'Search for feeds'
			params do
				optional :query, type: String, default: ''
				optional :auth_token, type: String
			end
			get do

				# normalize query
				query = params[:query].downcase

				# find feeds
				feeds = Feed.where 'lower(name) like ?', "%#{query}%"

				# limit to 20 results
				feeds = feeds.limit 20

				# present results
				present :feeds, feeds
			end

			route_param :id do

				desc 'Get feed information'
				params do
					optional :show_recents, type: Boolean, default: false
					optional :auth_token, type: String
				end
				get do

					# find feed
					feed = Feed.find_by id: params[:id]
					not_found! '404.1', 'Feed was not found' unless feed

					# check feed permission
					forbidden! unless @user.subscribed_to?(feed)

					# show feed
					present :feed, feed, show_recents: params[:show_recents]
				end

				desc 'Get messages in feed'
				params do
					optional :count, type: Integer, default: 20, values: 0..50
					optional :after_sequence, type: Integer, default: 0
					optional :auth_token, type: String
				end
				get do

					# find feed
					feed = Feed.find_by id: params[:id]
					not_found! '404.1', 'Feed was not found' unless feed

					# get messages
					messages = f.messages.after params[:after_sequence]

					# limit to desired count
					messages = messages.limit params[:count]

					# show messages
					present :messages, messages, show_feed: false
				end

			end
		end

		resource :users do
			route_param :id do

				desc 'Get users feeds'
				params do
					optional :auth_token, type: String
				end
				get :feeds do

					# find user
					user = User.find_by id: params[:id]
					not_found! '404.1', 'User was not found' unless user

					# ensure requester matches user
					forbidden! unless @user == user

					# show users feeds
					present :feeds, user.feeds, show_recents: true
				end

			end
		end
	end
end
