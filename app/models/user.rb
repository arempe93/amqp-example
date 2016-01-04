# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  amqp_xchg              :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  username               :string
#  name                   :string
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#  index_users_on_username              (username) UNIQUE
#

class User < ActiveRecord::Base

    ## Devise
    devise :database_authenticatable, :registerable,
        :recoverable, :trackable, :validatable

    ## Callbacks
    after_create :create_xhcg
    after_destroy :teardown_xchg

    ## Validations
    validates :email, uniqueness: { case_sensitive: false }
    validates :username, uniqueness: { case_sensitive: true }, format: { with: /\A(?![_\-.])([\w\.-]{3,30})(?<![_.])\Z/ }
    validates :name, format: { with: /\A(([a-z]|'|\.)+\s?){1,4}\Z/i }

    ## Relationships
    has_many :devices

    has_many :subscriptions
    has_many :feeds, through: :subscriptions, source: :feed

    ## Methods
    def subscribe!(feed)

        self.subscriptions.create! feed: feed
    end

    def unsubscribe!(feed)

        sub = self.subscriptions.find_by(feed_id: feed.id)

        raise ActiveRecord::RecordNotFound unless sub

        sub.destroy!
    end

    def subscribed_to?(feed)
        self.subscriptions.exists? feed_id: feed.id
    end

    def has_private_feed_with?(other)

        private_feeds = self.feeds.where feed_type: Enums::FeedType::PRIVATE

        Subscription.exists? feed_id: private_feeds, user_id: other.id
    end

    ## Private Methods
    private
    def create_xhcg

        # generate exchange name
        self.amqp_xchg = "xchg.user.#{self.id}"

        begin

            # create in rmq
            AMQP::Factory.create_exchange self.amqp_xchg

        rescue => e

            # log error
            Rails.logger.error "#<User id:#{self.id}>.create_xchg raised => '#{e.message}'"
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
            Rails.logger.error "#<User id:#{self.id}>.teardown_xchg raised => '#{e.message}'"
            Rails.logger.error "#{e.backtrace}"

        end
    end
end
