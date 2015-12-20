module API
    module Support
        module Errors

            ERROR_CODES = {
                400 => 'Bad Request',
                401 => 'Unauthorized',
                403 => 'Forbidden',
                404 => 'Not Found',
                422 => 'Not Processable',
                500 => 'Internal Server Error',
            }

            def error_response!(opts)

                error!({
                    response_code: opts[:response_code],
                    response_text: ERROR_CODES[opts[:response_code]],
                    error_code: opts[:code],
                    error_text: opts[:message] || ERROR_CODES[opts[:response_code]]
                }, opts[:response_code])
            end

            def bad_request!(code = '400', message = nil)

                error_response! response_code: 400, code: code, message: message
            end

            def unauthorized!(code = '401', message = nil)

                error_response! response_code: 401, code: code, message: message
            end

            def forbidden!(code = '403', message = nil)

                error_response! response_code: 403, code: code, message: message
            end

            def not_found!(code = '404', message = nil)

                error_response! response_code: 404, code: code, message: message
            end

            def unprocessable!(code = '422', message = nil)

                error_response! response_code: 422, code: code, message: message
            end

            def server_error!(code = '500', message = nil)

                error_response! response_code: 500, code: code, message: message
            end

        end
    end
end
