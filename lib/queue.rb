require 'bunny'

topic = ARGV.shift
msg = ARGV.join ' '

conn = Bunny.new
conn.start

channel = conn.create_channel
queue = channel.queue topic

queue.publish msg
puts "[x] Published message to #{topic}"

conn.close
