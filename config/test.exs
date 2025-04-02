import Config

# Test environment configuration
# For CI testing, we can use environment variables or mock values
config :carrier, Carrier,
  auth_id: System.get_env("SMARTY_AUTH_ID") || "test_auth_id",
  auth_token: System.get_env("SMARTY_AUTH_TOKEN") || "test_auth_token"

# You can also configure a mock server for testing if needed
# config :carrier, :mock_server, true
