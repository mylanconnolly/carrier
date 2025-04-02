import Config

# Production environment configuration
# Always use environment variables for sensitive data in production
config :carrier, Carrier,
  auth_id: System.get_env("SMARTY_AUTH_ID"),
  auth_token: System.get_env("SMARTY_AUTH_TOKEN")
