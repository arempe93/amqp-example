module API
    class Base < Grape::API

        prefix :api
        format :json

        helpers Support::Errors
        helpers Support::Auth

        before do
			header['Access-Control-Allow-Origin'] = '*'
			header['Access-Control-Allow-Methods'] = 'GET, POST, PUT, DELETE, OPTIONS'
			header['Access-Control-Allow-Headers'] = 'accept, content-type'
        end

        after_validation do
            @user, @device = authenticate! if declared(params).key?(:auth_token)
        end

        mount Auth
        mount Users

        add_swagger_documentation hide_format: true
    end
end
