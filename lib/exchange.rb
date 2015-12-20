require 'bunny'

xchg = ARGV.shift
msg = ARGV.join ' '

conn = Bunny.new
conn.start

channel = conn.create_channel
exchange = channel.fanout xchg, durable: true

exchange.publish msg
puts "[x] Published message to #{xchg}"

conn.close
