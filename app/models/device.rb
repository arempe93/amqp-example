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
#  index_devices_on_user_id     (user_id)
#

class Device < ActiveRecord::Base

	## Callbacks
	before_create :set_initial_request
	before_create :hash_access_token
	before_create :discover_os

	after_create :create_queue
	after_destroy :teardown_queue

	## Validations
	validates :uuid, format: { with: /\A([abcdef0-9]+\-?)+\Z/ }

	## Relationships
	belongs_to :user

	## Methods
	def update_last_request!
		update_attribute :last_request, Time.now
	end

	## Class Methods
	def self.generate(attrs = {})

		# generate 24 byte random token
		auth_token = SecureRandom.urlsafe_base64 24

		# create new device instance
		Device.new attrs.merge(token_hash: auth_token)
	end

	def self.authenticate!(token)

		# find device for token
		Device.find_by! token_hash: Digest::SHA256.hexdigest(token)
	end

	## Private Methods
	private
	def set_initial_request
	
		# set last request to current time on create
		self.last_request = Time.now

		# continue creation
		true
	end

	def hash_access_token

		# md5 hash the auth token
		self.token_hash = Digest::SHA256.hexdigest self.token_hash

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
		self.amqp_queue = "queue.device.#{self.id}.#{self.mobile}"

		begin

			# bind to user exchange
			AMQP::Factory.create_queue self.amqp_queue, self.user.amqp_xchg

		rescue => e

			# log error
			Rails.logger.error "Device.create_queue raised => '#{e.message}'"
			Rails.logger.error "#{e.backtrace}"

			# bubble up call stack
			raise

		else

			# save queue name
			self.save!
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
