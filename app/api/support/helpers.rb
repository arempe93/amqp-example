module API
	module Support
		module Helpers
		
			def set(params)
				params.delete :auth_token
				declared(params).to_hash.compact.deep_symbolize_keys
			end

		end
	end
end