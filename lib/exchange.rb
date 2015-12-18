require 'bunny'

xchg = ARGV.shift
xchg_type = ARGV.shift
msg = ARGV.join ' '

conn = Bunny.new
conn.start

channel = conn.create_channel
exchange = channel.exchange xchg, type: xchg_type

exchange.publish msg
puts "[x] Published message to #{xchg}"

conn.close
