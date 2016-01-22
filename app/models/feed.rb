# == Schema Information
#
# Table name: feeds
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  feed_type  :integer          not null
#  amqp_xchg  :string
#  creator_id :integer
#
# Indexes
#
#  index_feeds_on_creator_id  (creator_id)
#  index_feeds_on_name        (name) UNIQUE
#

class Feed < ActiveRecord::Base

	## Callbacks
	after_create :create_xhcg
    after_destroy :teardown_xchg

	## Validations
	validates :name, format: { with: /\A(.+\s?)+\Z/i }
    validates :creator_id, presence: true

	## Relationships
    belongs_to :creator, class_name: 'User'
    
	has_many :subscriptions
	has_many :subscribers, through: :subscriptions, source: :user

	has_many :messages, -> { order(feed_sequence: :asc) }

	## Methods
	def send!(sender, payload)

		self.messages.create! sender: sender, payload: payload, message_type: Enums::MessageType::CHAT
	end

	def next_message_sequence

		(self.messages.maximum(:feed_sequence) || 0) + 1
	end

    def private?
        self.feed_type = Enums::FeedType::PRIVATE
    end

    def group?
        self.feed_type = Enums::FeedType::GROUP
    end

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
            Rails.logger.error "#<Feed id:#{self.id}>.create_xchg raised => '#{e.message}'"
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
