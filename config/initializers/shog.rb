Shog.configure do

	if ::Rails.env.production?
		reset_config!
		timestamp
	end

	match /REQUEST|QUERY/ do |msg, matches|

		msg.green
	end
end