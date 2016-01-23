module API
	class Base < Grape::API

		use Middleware::APILogger
		use Middleware::ErrorHandler

		prefix :api
		format :json

		helpers Support::Errors
		helpers Support::Auth
		helpers Support::Helpers

		after_validation do
			@user, @device = authenticate! if declared(params).key?(:auth_token)
		end

		mount Auth
		mount Users
		mount Feeds

		add_swagger_documentation hide_format: true
	end
end
