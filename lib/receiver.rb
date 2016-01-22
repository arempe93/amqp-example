require 'bunny'

topic = ARGV.shift

conn = Bunny.new
conn.start

queue = conn.channel.queue topic, durable: true

puts "[x] Connected to #{topic}\n"

queue.subscribe block: true do |delivery_info, properties, body|

    puts body
    puts "\t#{properties.inspect}"
end
