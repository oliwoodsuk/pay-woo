# Testing with Real WooCommerce API

This gem uses VCR to record real HTTP interactions with the WooCommerce API for testing.

## Important: Tests WILL FAIL without real credentials

The tests are designed to fail with authentication errors when using dummy credentials. This ensures we're testing against real API responses, not mocked ones.

## Setup for Testing

1. Copy the test environment file:
   ```bash
   cp .env.test.example .env.test
   ```

2. Add your **real** WooCommerce sandbox credentials to `.env.test`:
   ```
   WOOCOMMERCE_URL=https://your-sandbox-site.com
   WOOCOMMERCE_CONSUMER_KEY=ck_your_actual_consumer_key
   WOOCOMMERCE_CONSUMER_SECRET=cs_your_actual_consumer_secret
   ```

3. Run tests to record VCR cassettes with real API responses:
   ```bash
   bundle exec rake test
   ```

**Without real credentials, tests will fail with Pay::Woo::AuthenticationError - this is expected and correct behavior.**

## VCR Cassettes

- VCR cassettes are stored in `test/vcr_cassettes/`
- Sensitive data (API keys, URLs) are automatically filtered out
- To re-record cassettes, delete the existing ones and run tests again
- Real API credentials are only needed when recording new cassettes

## WooCommerce Sandbox Setup

1. Create a WooCommerce sandbox/test store
2. Go to WooCommerce > Settings > Advanced > REST API
3. Create new API keys with Read/Write permissions
4. Use these credentials in your `.env.test` file

The tests will make real API calls to verify:
- Authentication and authorization
- Error handling for various HTTP status codes
- Request/response parsing
- Retry logic for rate limits and server errors