require 'bunny'

module AMQP
    class Factory

        ####################################################
        #   Connection Management
        ####################################################

        def self.connect

            # create bunny rmq client
            @connection = Bunny.new

            # make connection
            @connection.start

            # return connection
            @connection
        end

        def self.get_channel

            # make connection if not connected
            connect unless defined?(@connection) and @connection.open?

            # get channel
            @connection.channel
        end

        ####################################################
        #   Exchange Management
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
                channel.close
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
                channel.close
            end
        end

        ####################################################
        #   Binding Management
        ####################################################

        def self.bind_exchange(source_name, receiver_name)

            begin

                # get channel
                channel = get_channel

                # get source exchange
                source = channel.fanout source_name, durable: true

                # bind receiver to source
                source.bind receiver_name, routing_key: receiver_name

            rescue => e

                # log errors
                Rails.logger.error "AMQP::Factory::bind_exchange raised => '#{e.message}'"
                Rails.logger.error "#{e.backtrace}"

                # bubble up call stack
                raise

            ensure

                # close channel
                channel.close
            end
        end

        def self.unbind_exchange(source_name, receiver_name)

            begin

                # get channel
                channel = get_channel

                # get source exchange
                source = channel.fanout source_name, durable: true

                # unbind receiver from source
                source.unbind receiver_name, routing_key: receiver_name

            rescue => e

                # log errors
                Rails.logger.error "AMQP::Factory::unbind_exchange raised => '#{e.message}'"
                Rails.logger.error "#{e.backtrace}"

                # bubble up call stack
                raise

            ensure

                # close channel
                channel.close
            end
        end

        ####################################################
        #   Queue Management
        ####################################################

        def self.create_queue(name, xchg_name)

            begin

                # get channel
                channel = get_channel

                # get exchange to create in
                xchg = channel.fanout xchg_name,durable: true

                # create queue
                queue = channel.queue name

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
                channel.close
            end
        end

        def self.teardown_queue(name)

            begin

                # get channel
                channel = get_channel

                # get queue
                queue = channel.queue name

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
                channel.close
            end
        end

        ####################################################
        #   Message Processing
        ####################################################

        def self.publish(message, xchg_name, opts = {})

            # set content type of delivery
            opts.merge! content_type: 'application/json'

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
                channel.close
            end
        end

    end
end
