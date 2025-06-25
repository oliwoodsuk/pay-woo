require "test_helper"

class Pay::Woo::ClientTest < ActiveSupport::TestCase
  def setup
    @client = Pay::Woo::Client.new(
      consumer_key: ENV["WOOCOMMERCE_CONSUMER_KEY"] || "test_key",
      consumer_secret: ENV["WOOCOMMERCE_CONSUMER_SECRET"] || "test_secret",
      base_url: ENV["WOOCOMMERCE_URL"] || "https://example.com"
    )
  end

  test "initializes with correct credentials" do
    assert_equal ENV["WOOCOMMERCE_CONSUMER_KEY"] || "test_key", @client.consumer_key
    assert_equal ENV["WOOCOMMERCE_CONSUMER_SECRET"] || "test_secret", @client.consumer_secret
    assert_equal 30, @client.timeout
  end

  test "raises error without consumer_key" do
    assert_raises ArgumentError do
      Pay::Woo::Client.new(consumer_secret: "secret", base_url: "https://example.com")
    end
  end

  test "raises error without consumer_secret" do
    assert_raises ArgumentError do
      Pay::Woo::Client.new(consumer_key: "key", base_url: "https://example.com")
    end
  end

  test "raises error without base_url" do
    assert_raises ArgumentError do
      Pay::Woo::Client.new(consumer_key: "key", consumer_secret: "secret")
    end
  end

  test "normalizes base URL correctly" do
    client = Pay::Woo::Client.new(
      consumer_key: "key",
      consumer_secret: "secret",
      base_url: "https://example.com"
    )
    assert_equal "https://example.com/wp-json/wc/v3", client.base_url
  end

  test "handles base URL with existing wp-json path" do
    client = Pay::Woo::Client.new(
      consumer_key: "key",
      consumer_secret: "secret",
      base_url: "https://example.com/wp-json/wc/v3"
    )
    assert_equal "https://example.com/wp-json/wc/v3", client.base_url
  end

  test "fetches products from WooCommerce API" do
    VCR.use_cassette("woocommerce_products") do
      response = @client.get("/products")
      assert response.is_a?(Array) || response.is_a?(Hash)
    end
  end

  test "handles authentication error" do
    VCR.use_cassette("woocommerce_auth_error") do
      client = Pay::Woo::Client.new(
        consumer_key: "invalid_key",
        consumer_secret: "invalid_secret",
        base_url: ENV["WOOCOMMERCE_URL"] || "https://example.com"
      )
      
      assert_raises Pay::Woo::AuthenticationError do
        client.get("/products")
      end
    end
  end

  test "handles not found error" do
    VCR.use_cassette("woocommerce_not_found") do
      assert_raises Pay::Woo::NotFoundError do
        @client.get("/nonexistent-endpoint")
      end
    end
  end

  test "creates a customer via POST" do
    VCR.use_cassette("woocommerce_create_customer") do
      customer_data = {
        email: "test@example.com",
        first_name: "Test",
        last_name: "User"
      }
      
      response = @client.post("/customers", customer_data)
      assert response.is_a?(Hash)
      assert response["email"] == "test@example.com"
    end
  end
end