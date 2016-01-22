require 'bunny'

module AMQP
	module Factory

		## Connection, can be mocked for tests
		mattr_accessor :connection

		####################################################
		#	Connection Management
		####################################################

		def self.connect

			# create bunny rmq client
			@@connection = Bunny.new Global.amqp.to_hash

			# make connection
			@@connection.start

			# return connection
			@@connection
		end

		def self.get_channel

			# make connection if not connected
			connect unless @@connection and @@connection.open?

			# get channel
			@@connection.channel
		end

		####################################################
		#	Exchange Management
		####################################################

		def self.create_exchange(name)

			begin

				# get channel
				channel = get_channel

				# create exchange
				channel.fanout name, durable: true

			rescue => e

				# log errors
				Rails.logger.error "AMQP::Factory::create_exchange raised => '#{e.message}'"
				Rails.logger.error "#{e.backtrace}"

				# bubble up call stack
				raise

			ensure

				# close channel
				channel.close if channel
			end
		end

		def self.teardown_exchange(name)

			begin

				# get channel
				channel = get_channel

				# get exchange
				xchg = channel.fanout name, durable: true

				# teardown exchange
				xchg.delete

			rescue => e

				# log errors
				Rails.logger.error "AMQP::Factory::teardown_exchange raised => '#{e.message}'"
				Rails.logger.error "#{e.backtrace}"

				# bubble up call stack
				raise

			ensure

				# close channel
				channel.close if channel
			end
		end

		####################################################
		#	Binding Management
		####################################################

		def self.bind_exchange(source_name, receiver_name)

			begin

				# get channel
				channel = get_channel

				# get receiver exchange
				receiver = channel.fanout receiver_name, durable: true

				# bind receiver to source
				receiver.bind source_name

			rescue => e

				# log errors
				Rails.logger.error "AMQP::Factory::bind_exchange raised => #{e.class.name}: '#{e.message}'"
				Rails.logger.error "(#{source_name}, #{receiver_name})"
				Rails.logger.error "#{e.backtrace}"

				# bubble up call stack
				raise

			ensure

				# close channel
				channel.close if channel
			end
		end

		def self.unbind_exchange(source_name, receiver_name)

			begin

				# get channel
				channel = get_channel

				# get receiver exchange
				receiver = channel.fanout receiver_name, durable: true

				# unbind receiver from source
				receiver.unbind source_name

			rescue => e

				# log errors
				Rails.logger.error "AMQP::Factory::unbind_exchange raised => '#{e.message}'"
				Rails.logger.error "(#{source_name}, #{receiver_name})"
				Rails.logger.error "#{e.backtrace}"

				# bubble up call stack
				raise

			ensure

				# close channel
				channel.close if channel
			end
		end

		####################################################
		#	Queue Management
		####################################################

		def self.create_queue(name, xchg_name)

			begin

				# get channel
				channel = get_channel

				# get exchange to create in
				xchg = channel.fanout xchg_name, durable: true

				# create queue
				queue = channel.queue name, durable: true

				# bind queue to exchange
				queue.bind xchg

			rescue => e

				# log errors
				Rails.logger.error "AMQP::Factory::create_queue raised => '#{e.message}'"
				Rails.logger.error "#{e.backtrace}"

				# bubble up call stack
				raise

			ensure

				# close channel
				channel.close if channel
			end
		end

		def self.teardown_queue(name)

			begin

				# get channel
				channel = get_channel

				# get queue
				queue = channel.queue name, durable: true

				# delete queue
				queue.delete

			rescue => e

				# log errors
				Rails.logger.error "AMQP::Factory::teardown_queue raised => '#{e.message}'"
				Rails.logger.error "#{e.backtrace}"

				# bubble up call stack
				raise

			ensure

				# close channel
				channel.close if channel
			end
		end

		####################################################
		#	Message Processing
		####################################################

		def self.publish(message, xchg_name, opts = {})

			begin

				# get channel
				channel = get_channel

				# get exchange
				xchg = channel.fanout xchg_name, durable: true

				# publish message
				xchg.publish message.to_json, opts

			rescue => e

				# log errors
				Rails.logger.error "AMQP::Factory::publish raised => '#{e.message}'"
				Rails.logger.error "#{e.backtrace}"

				# bubble up call stack
				raise

			ensure

				# close channel
				channel.close if channel
			end
		end

		####################################################
		#	Administration
		####################################################

		def self.clear
			`rabbitmqadmin -f tsv list exchanges name | grep ^xchg | while read xchg; do rabbitmqadmin -q delete exchange name="${xchg}"; done`
			`rabbitmqadmin -f tsv list queues name | grep ^queue | while read q; do rabbitmqadmin -q delete queue name="${q}"; done`
		end

	end
end
