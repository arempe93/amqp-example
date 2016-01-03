module API
	module Entities
		class Message < Grape::Entity

			expose :id, :feed_sequence, :payload, :message_type, :sent_at

			expose :options do |message, opts|
				message.options.to_hash
			end

			expose :sender, with: Entities::User

			expose :feed, with: Entities::Feed, if: lambda { |message, opts| opts[:show_feed] }

		end
	end
end
