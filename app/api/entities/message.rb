module API
	module Entities
		class Message < Grape::Entity

			expose :id, :payload, :options, :message_type, :sent_at

			expose :sender, with: Entities::User

			expose :feed, with: Entities::Feed, if: lambda { |message, opts| opts[:show_feed] }

		end
	end
end
