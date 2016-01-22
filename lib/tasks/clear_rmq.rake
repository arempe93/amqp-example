namespace :rmq do

	desc 'Clear all queues and exchanges from RMQ'
	task :clear => [:environment] do
		
		AMQP::Factory.clear
	end
end
