require "httparty"
require "base64"
require "json"
require "net/http"
require "timeout"

module Pay
  module Woo
    class Client
      include HTTParty
      
      # WooCommerce REST API endpoints
      # These should be configured per-store, not hardcoded
      DEFAULT_API_VERSION = "v3"
      
      attr_reader :consumer_key, :consumer_secret, :base_url, :timeout
      
      def initialize(consumer_key: nil, consumer_secret: nil, base_url: nil, timeout: 30)
        @consumer_key = consumer_key || Pay::Woo.configuration.consumer_key
        @consumer_secret = consumer_secret || Pay::Woo.configuration.consumer_secret
        @base_url = base_url || Pay::Woo.configuration.woocommerce_url
        @timeout = timeout || Pay::Woo.configuration.timeout
        
        raise ArgumentError, "consumer_key is required" unless @consumer_key
        raise ArgumentError, "consumer_secret is required" unless @consumer_secret
        raise ArgumentError, "base_url is required" unless @base_url
        
        # Ensure base_url ends with wp-json/wc/v3
        @base_url = normalize_base_url(@base_url)
        
        self.class.base_uri(@base_url)
        self.class.default_timeout(@timeout)
        
        # Configure HTTParty headers
        self.class.headers({
          "Content-Type" => "application/json",
          "Accept" => "application/json",
          "Authorization" => "Basic #{encoded_credentials}"
        })
      end
      
      def get(path, options = {})
        request(:get, path, options)
      end
      
      def post(path, body = {}, options = {})
        request(:post, path, options.merge(body: body.to_json))
      end
      
      def put(path, body = {}, options = {})
        request(:put, path, options.merge(body: body.to_json))
      end
      
      def delete(path, options = {})
        request(:delete, path, options)
      end
      
      private
      
      def normalize_base_url(url)
        # Remove trailing slash
        url = url.chomp("/")
        
        # Add WooCommerce REST API path if not present
        unless url.include?("/wp-json/wc/")
          url += "/wp-json/wc/#{DEFAULT_API_VERSION}"
        end
        
        url
      end
      
      def encoded_credentials
        Base64.strict_encode64("#{@consumer_key}:#{@consumer_secret}")
      end
      
      def request(method, path, options = {})
        retries = 0
        max_retries = 3
        
        begin
          response = self.class.send(method, path, options)
          handle_response(response)
        rescue Net::OpenTimeout, Net::ReadTimeout, Timeout::Error => e
          raise Pay::Woo::TimeoutError, "Request timed out: #{e.message}"
        rescue SocketError, Errno::ECONNREFUSED, Errno::EHOSTUNREACH => e
          raise Pay::Woo::NetworkError, "Network error: #{e.message}"
        rescue Pay::Woo::RateLimitError => e
          if retries < max_retries
            retries += 1
            sleep(2 ** retries) # Exponential backoff
            retry
          else
            raise e
          end
        rescue Pay::Woo::ServerError => e
          if retries < max_retries
            retries += 1
            sleep(1)
            retry
          else
            raise e
          end
        end
      end
      
      def handle_response(response)
        case response.code
        when 200..299
          parse_response_body(response)
        when 400
          raise Pay::Woo::BadRequestError, error_message(response)
        when 401
          raise Pay::Woo::AuthenticationError, "Invalid API credentials"
        when 403
          raise Pay::Woo::AuthorizationError, "Insufficient permissions"
        when 404
          raise Pay::Woo::NotFoundError, "Resource not found"
        when 429
          raise Pay::Woo::RateLimitError, "Rate limit exceeded"
        when 500..599
          raise Pay::Woo::ServerError, "Server error: #{response.code}"
        else
          raise Pay::Woo::APIError.new(
            "Unexpected response: #{response.code}",
            code: response.code,
            http_status: response.code,
            response_body: response.body
          )
        end
      end
      
      def parse_response_body(response)
        return {} if response.body.nil? || response.body.empty?
        
        JSON.parse(response.body)
      rescue JSON::ParserError
        response.body
      end
      
      def error_message(response)
        parsed_body = parse_response_body(response)
        
        if parsed_body.is_a?(Hash)
          parsed_body.dig("message") || parsed_body.dig("error", "message") || "Unknown error"
        else
          "HTTP #{response.code}: #{response.message}"
        end
      end
    end
  end
end