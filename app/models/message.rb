# == Schema Information
#
# Table name: messages
#
#  id            :integer          not null, primary key
#  user_id       :integer
#  feed_id       :integer
#  feed_sequence :integer
#  message_type  :integer
#  payload       :string
#  options       :hstore
#  sent_at       :datetime
#
# Indexes
#
#  index_messages_on_feed_id  (feed_id)
#  index_messages_on_user_id  (user_id)
#

class Message < ActiveRecord::Base

	## Callbacks
	before_create :add_metadata
	after_create :deliver

	## Relationships
	belongs_to :feed
	belongs_to :sender, class_name: 'User', foreign_key: 'user_id'

	## Scopes
	scope :after, lambda { |seq| where('feed_sequence > ?', seq) }

	## Private Methods
	private
	def add_metadata

		# create timestamp
		self.sent_at = DateTime.now

		# add feed sequence
		self.feed_sequence = self.feed.next_message_sequence

		# add some rmq options
		self.options = {
			type: Enums::MessageType.t(self.message_type),
			user_id: self.sender.id,
			correlation_id: self.feed.id,
			timestamp: self.sent_at.to_i
		}

		# continue creation
		true
	end

	def deliver

		# add message id to delivery options
		self.options.merge! message_id: self.id
		self.save!

		# tell feed to send me
		self.feed.publish self
	end
end
