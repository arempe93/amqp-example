module API
	class Base < Grape::API

		prefix :api
		format :json

		helpers Support::Errors
		helpers Support::Auth

		after_validation do
		@user, @device = authenticate! if declared(params).key?(:auth_token)
		end

		mount Auth
		mount Users
		mount Feeds
		mount Subscriptions

		add_swagger_documentation hide_format: true
	end
end
