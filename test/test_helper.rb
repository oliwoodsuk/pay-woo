# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

# Load environment variables for testing
require "dotenv"
Dotenv.load(".env.test")

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [ File.expand_path("../test/dummy/db/migrate", __dir__) ]
require "rails/test_help"

# Load VCR for recording HTTP interactions
require "vcr"
require "webmock"

VCR.configure do |config|
  config.cassette_library_dir = "test/vcr_cassettes"
  config.hook_into :webmock
  config.ignore_localhost = true
  config.default_cassette_options = {
    record: :once,
    match_requests_on: [:method, :uri, :body]
  }
  
  # Filter sensitive data
  config.filter_sensitive_data('<WOOCOMMERCE_CONSUMER_KEY>') { ENV['WOOCOMMERCE_CONSUMER_KEY'] }
  config.filter_sensitive_data('<WOOCOMMERCE_CONSUMER_SECRET>') { ENV['WOOCOMMERCE_CONSUMER_SECRET'] }
  config.filter_sensitive_data('<WOOCOMMERCE_URL>') { ENV['WOOCOMMERCE_URL'] }
end

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_paths=)
  ActiveSupport::TestCase.fixture_paths = [ File.expand_path("fixtures", __dir__) ]
  ActionDispatch::IntegrationTest.fixture_paths = ActiveSupport::TestCase.fixture_paths
  ActiveSupport::TestCase.file_fixture_path = File.expand_path("fixtures", __dir__) + "/files"
  ActiveSupport::TestCase.fixtures :all
end
