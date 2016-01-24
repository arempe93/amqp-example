module API
	class Feeds < Grape::API

		represent Feed, with: API::Entities::Feed
		represent Message, with: API::Entities::Message

		resource :feeds do

			desc 'Create a new feed'
			params do
				optional :name, type: String
				requires :type, type: Integer, values: Enums::FeedType.list
				optional :user_id, type: Integer
				optional :auth_token, type: String
			end
			post do

				# filter out nil params
				attrs = set(params)

				# create array of subscribers to add to feed
				subscribers = []

				# add self as a subscriber
				subscribers << @user

				if attrs[:type] == Enums::FeedType::GROUP

					# create feed
					feed = Feed.new name: attrs[:name], feed_type: attrs[:type], creator: @user

				else

					# ensure another user was provided
					bad_request! '400.1', 'Missing param: user_id' unless attrs[:user_id]

					# find user
					user = User.find_by id: attrs[:user_id]
					not_found! '404.1', 'User was not found' unless user

					# ensure private feed between users does not already exist
					unprocessable! '422.2', 'Private feed between users already exists' if @user.has_private_feed_with?(user)

					# create feed
					feed = Feed.new name: "Private Chat: #{@user.username} - #{user.username}", feed_type: attrs[:type], creator: @user

					# subscribe other user
					subscribers << user
				end

				# validate feed
				validate! feed, '422.1'

				begin

					ActiveRecord::Base.transaction do

						# save feed
						feed.save!

						# save all subscriptions
						subscribers.each do |user|
							user.subscribe! feed
						end
					end

				rescue => e

					server_error! '500.1', e.message

				else

					# show new feed
					present :feed, feed, show_recents: false
				end
			end

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

				after_validation do

					# find feed
					@feed = Feed.find_by id: params[:id]
					not_found! '404.1', 'Feed was not found' unless @feed

					# check feed permission
					forbidden! unless @user.subscribed_to?(@feed)
				end

				desc 'Get feed information'
				params do
					optional :show_recents, type: Boolean, default: false
					optional :auth_token, type: String
				end
				get do

					# show feed
					present :feed, @feed, show_recents: params[:show_recents]
				end

				desc 'Update feed information'
				params do
					optional :name, type: String
				end
				put do

					attrs = set(params)

					# only allow feed creator to edit
					forbidden! unless @feed.creator == @user

					# dont allow editing private groups
					unprocessable! '422.1', 'Cannot edit private feed information' if @feed.private?

					# update feed
					@feed.update_attributes attrs

					# show feed
					present :feed, @feed
				end

				desc 'Subscribe to a feed'
				params do
					optional :auth_token, type: String
				end
				post :subscribe do

					# dont allow subscriptions to private feeds
					unprocessable! '422.1', 'Cannot subscribe to a private feed' if @feed.private?

					# subscribe
					@user.subscribe! @feed

					# show updated feed
					present :feed, @feed
				end

				desc 'Unsubscribe from a feed'
				params do
					optional :auth_token, type: String
				end
				delete :unsubscribe do

					# dont allow unsubscriptions from private feeds
					unprocessable! '422.1', 'Cannot unsubscribe from a private feed' if @feed.private?

					begin

						# subscribe
						@user.unsubscribe! @feed

					rescue ActiveRecord::RecordNotFound => e

						# user was not subscribed
						not_found! '404.2', e.message
					end

					# show updated feed
					present :feed, @feed
				end

				resource :messages do

					desc 'Send message in feed'
					params do
						requires :payload, type: String
						optional :auth_token, type: String
					end
					post do

						# create message
						message = @feed.send! @user, params[:payload]

						# return message
						present :message, message, show_feed: false
					end

					desc 'Get messages in feed'
					params do
						optional :count, type: Integer, default: 20, values: 0..50
						optional :after_sequence, type: Integer, default: 0
						optional :auth_token, type: String
					end
					get do

						# get messages
						messages = @feed.messages.after params[:after_sequence]

						# limit to desired count
						messages = messages.limit params[:count]

						# show messages
						present :messages, messages, show_feed: false
					end

				end
			end
		end
	end
end
