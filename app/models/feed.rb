# == Schema Information
#
# Table name: feeds
#
#  id        :integer          not null, primary key
#  name      :string           not null
#  feed_type :integer          not null
#  amqp_xchg :string
#
# Indexes
#
#  index_feeds_on_name  (name) UNIQUE
#

class Feed < ActiveRecord::Base

	## Callbacks
	after_create :create_xhcg
    after_destroy :teardown_xchg

	## Validations
	validates :name, uniqueness: { case_sensitive: true }, format: { with: /\A(([a-z]|'|\.)+\s?)+\Z/i }

	## Private Methods
    private
    def create_xhcg

        # generate exchange name
        self.amqp_xchg = "xchg.feed.#{self.id}"

        begin

            # create in rmq
            AMQP::Factory.create_exchange self.amqp_xchg

        rescue => e

            # log error
            Rails.logger.error "Feed.create_xchg raised => '#{e.message}'"
            Rails.logger.error "#{e.backtrace}"

            # bubble up call stack
            raise

        else

            # save exchange name
            self.save!
        end
    end

    def teardown_xchg

        begin

            # remove from rmq
            AMQP::Factory.teardown_exchange self.amqp_xchg

        rescue => e

            # log error
            Rails.logger.error "#<Feed id:#{self.id}>.teardown_xchg raised => '#{e.message}'"
            Rails.logger.error "#{e.backtrace}"

        end
    end
end