module API
	module Entities
		class Feed < Grape::Entity

			expose :id, :name, :feed_type

			expose :creator, with: Entities::User

			expose :subscribers, with: Entities::User

			expose :messages, with: Entities::Message, if: lambda { |feed, opts| opts[:show_recents] }

		end
	end
end
