require 'bunny'

topic = ARGV.shift

conn = Bunny.new
conn.start

queue = conn.channel.queue topic

puts "[x] Connected to #{topic}\n"

queue.subscribe block: true do |delivery_info, properties, body|

    puts body
    puts "\t#{delivery_info.inspect}"
    puts "\t#{properties.inspect}"
end
