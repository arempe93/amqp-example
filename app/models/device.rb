# == Schema Information
#
# Table name: devices
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  uuid         :string
#  os           :integer
#  mobile       :boolean
#  user_agent   :string
#  amqp_queue   :string
#  token_hash   :string
#  last_request :datetime
#
# Indexes
#
#  index_devices_on_token_hash  (token_hash) UNIQUE
#  index_devices_on_user_id     (user_id) UNIQUE
#

class Device < ActiveRecord::Base

    ## Callbacks
    before_create :hash_access_token
    before_create :discover_os
    before_create :create_queue

    after_destroy :teardown_queue

    ## Relationships
    belongs_to :user

    ## Class Methods
    def self.generate(attrs = {})

        # generate 24 byte random token
        auth_token = SecureRandom.urlsafe_base64 24

        # create new device
        Device.new attrs.merge(token_hash: auth_token)
    end

    def self.authenticate!(token)

        # find device for token
        Device.find_by! token_hash: Digest::MD5.hexdigest(token)
    end

    ## Private Methods
    private
    def hash_access_token

        # md5 hash the auth token
        self.token_hash = Digest::MD5.hexdigest self.token_hash

        # continue creation
        true
    end

    def discover_os

        # get os from user_agent
        self.os = Enums::DeviceOS.from_user_agent self.user_agent

        # continue creation
        true
    end

    def create_queue

        # generate queue name
        self.amqp_queue = "queue.#{self.user.id}.#{self.mobile}.#{Enums::DeviceOS.t(self.os).downcase}.#{self.uuid.split('-')[0]}"

        begin

            # bind to user exchange
            AMQP::Factory.create_queue self.amqp_queue, self.user.amqp_xchg

        rescue => e

            # log error
            Rails.logger.error "#<Device id:#{self.id}>.create_queue raised => '#{e.message}'"
            Rails.logger.error "#{e.backtrace}"

            # bubble up call stack
            raise

        else

            # continue creation
            true
        end
    end

    def teardown_queue

        begin

            # remove from rmq
            AMQP::Factory.teardown_queue self.amqp_queue

        rescue => e

            # log error
            Rails.logger.error "#<Device id:#{self.id}>.teardown_queue raised => '#{e.message}'"
            Rails.logger.error "#{e.backtrace}"

        end
    end
end
