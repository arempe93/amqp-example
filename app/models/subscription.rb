# == Schema Information
#
# Table name: subscriptions
#
#  id      :integer          not null, primary key
#  user_id :integer
#  feed_id :integer
#
# Indexes
#
#  index_subscriptions_on_feed_id  (feed_id)
#  index_subscriptions_on_user_id  (user_id)
#

class Subscription < ActiveRecord::Base

	## Callbacks
	after_create :bind_to_feed
	after_destroy :unbind_from_feed

	## Relationships
	belongs_to :user
	belongs_to :feed

	## Private Methods
	private
	def bind_to_feed

		begin

            # bind user exchange to feed
            AMQP::Factory.bind_exchange self.feed.amqp_xchg, self.user.amqp_xchg

        rescue => e

            # log error
            Rails.logger.error "#<Subscription id:#{self.id}>.bind_to_feed raised => '#{e.message}'"
			Rails.logger.error "(#<Feed id:#{self.feed.id}>, #<User id:#{self.user.id}>)"
            Rails.logger.error "#{e.backtrace}"
        end
	end

	def unbind_from_feed

		begin

            # bind user exchange to feed
            AMQP::Factory.unbind_exchange self.feed.amqp_xchg, self.user.amqp_xchg

        rescue => e

            # log error
            Rails.logger.error "#<Subscription id:#{self.id}>.unbind_from_feed raised => '#{e.message}'"
			Rails.logger.error "(#<Feed id:#{self.feed.id}>, #<User id:#{self.user.id}>)"
            Rails.logger.error "#{e.backtrace}"
        end
	end
end
