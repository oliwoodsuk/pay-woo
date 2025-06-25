require "pay/woo/version"
require "pay/woo/railtie"
require "pay/woo/error"
require "pay/woo/client"

module Pay
  module Woo
    class Configuration
      attr_accessor :woocommerce_url, :consumer_key, :consumer_secret, :timeout, :debug

      def initialize
        @woocommerce_url = nil
        @consumer_key = nil
        @consumer_secret = nil
        @timeout = 30
        @debug = false
      end
    end

    class << self
      attr_writer :configuration

      def configuration
        @configuration ||= Configuration.new
      end

      def configure
        yield(configuration)
      end

      def reset_configuration!
        @configuration = Configuration.new
      end
    end
  end
end
