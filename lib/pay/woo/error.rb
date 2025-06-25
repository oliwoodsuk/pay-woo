module Pay
  module Woo
    class Error < StandardError; end

    class AuthenticationError < Error; end
    class AuthorizationError < Error; end
    class BadRequestError < Error; end
    class NotFoundError < Error; end
    class RateLimitError < Error; end
    class ServerError < Error; end
    class TimeoutError < Error; end
    class NetworkError < Error; end

    class APIError < Error
      attr_reader :code, :http_status, :response_body

      def initialize(message, code: nil, http_status: nil, response_body: nil)
        super(message)
        @code = code
        @http_status = http_status
        @response_body = response_body
      end
    end
  end
end