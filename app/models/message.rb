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
	after_create :publish

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

		# continue creation
		true
	end

	def publish

		# gather rmq metadata
		rmq_options = {
			message_id: self.id,
			type: Enums::MessageType.t(self.message_type),
			correlation_id: self.feed.id,
			timestamp: self.sent_at.to_i
		}

		# persist metadata
		self.options = rmq_options
		self.save!

		# add additional info for rmq consumers
		rmq_options.merge! headers: { sender_id: self.sender.id, feed_seq: self.feed_sequence }

		begin

			# publish message to exchange
			AMQP::Factory.publish self.payload, self.feed.amqp_xchg, rmq_options

		rescue => e

			# log error
			Rails.logger.error "#<Message id:#{self.id}>.publish raised => #{e.class.name}: '#{e.message}'"
            Rails.logger.error "#{e.backtrace}"

			# bubble up call stack
			raise
		end
	end
end
