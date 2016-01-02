# == Schema Information
#
# Table name: messages
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  feed_id      :integer
#  message_type :integer
#  payload      :string
#  options      :hstore
#  sent_at      :datetime
#
# Indexes
#
#  index_messages_on_feed_id  (feed_id)
#  index_messages_on_user_id  (user_id)
#

class Message < ActiveRecord::Base

	## Callbacks
	after_create :deliver

	## Relationships
	belongs_to :feed
	belongs_to :sender, class_name: 'User', foreign_key: 'user_id'

	## Private Methods
	private
	def deliver

		# create timestamp
		self.sent_at = DateTime.now

		# create message delivery opts
		self.options = {
			message_id: self.id,
			type: Enums::MessageType.t(self.message_type),
			user_id: self.sender.id,
			correlation_id: self.feed.id,
			timestamp: self.sent_at.to_i
		}

		# save message data
		self.save!

		# tell feed to send me
		self.feed.publish self
	end
end
