require 'bunny'

topic = ARGV.shift
xchg, xchg_type = ARGV

conn = Bunny.new
conn.start

channel = conn.create_channel

if xchg

    exchange = channel.exchange xchg, type: xchg_type
    queue = channel.queue topic
    queue.bind exchange
    puts "[x] Connected to #{xchg} on queue #{topic}"

else

    queue = channel.queue topic
    puts "[x] Connected to #{topic}\n"
end

queue.subscribe block: true do |delivery_info, properties, body|

    puts body
    puts "\t#{properties.inspect}"
end
