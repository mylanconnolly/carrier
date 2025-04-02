import Config

# Development environment configuration
config :carrier, Carrier,
  auth_id: System.get_env("SMARTY_AUTH_ID"),
  auth_token: System.get_env("SMARTY_AUTH_TOKEN")
