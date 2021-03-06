##
##	Clear all AMQP data
##

puts 'Deleting amqp exchanges and queues...'

AMQP::Factory.clear

puts '[x] DONE'

##
##	Create users
##

puts 'Creating users...'

10.times do

	name = Faker::Name.name

	User.create! name: name, username: Faker::Internet.user_name(name, %w(. _ -)), password: 'Password1'
end

puts '[x] Done'

##
##	Create devices
##

PROFILES = [
	{
		user_agent: 'Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36',
		mobile: false
	},
	{
		user_agent: 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_4) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36',
		mobile: false
	},
	{
		user_agent: 'Mozilla/5.0 (Linux; U; Android 4.0.3; ko-kr; LG-L160L Build/IML74K) AppleWebkit/534.30 (KHTML, like Gecko) Version/4.0 Mobile Safari/534.30',
		mobile: true
	},
	{
		user_agent: 'Mozilla/5.0 (iPad; CPU OS 5_1 like Mac OS X) AppleWebKit/534.46 (KHTML, like Gecko ) Version/5.1 Mobile/9B176 Safari/7534.48.3',
		mobile: true
	}
]

puts 'Creating devices...'

tokens = []

User.all.each do |user|

	device = Device.generate PROFILES.sample.merge({ user: user, uuid: SecureRandom.uuid })
	tokens << device.token_hash
	device.save!
end

File.write "#{Rails.root}/devices.txt", tokens.join("\n")

puts '[x] Done'

##
##	Create feeds
##

private_feeds	= Array.new
group_feeds 	= Array.new

puts 'Creating feeds...'

5.times do

	feed_type = Enums::FeedType.list.sample
	feed = Feed.create! name: Faker::Lorem.sentence, feed_type: feed_type, creator: User.all.to_a.sample

	if feed_type == Enums::FeedType::PRIVATE

		private_feeds << feed

	else

		group_feeds << feed
	end
end

puts '[x] Done'

##
##	Create feed subscriptions
##

puts 'Creating subscriptions...'

private_feeds.each do |feed|

	User.all.to_a.sample(2).each do |user|

		Subscription.create! user: user, feed: feed
	end
end

group_feeds.each do |feed|

	User.all.to_a.sample(rand(2..5)).each do |user|

		Subscription.create! user: user, feed: feed
	end
end

puts '[x] Done'

##
##	Create messages
##

puts 'Creating messages...'

Feed.all.each do |feed|

	feed.subscribers.each do |user|

		Message.create! feed: feed, sender: user, message_type: Enums::MessageType::CHAT, payload: Faker::Lorem.sentence
	end
end

puts '[x] Done'
