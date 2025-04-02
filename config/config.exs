import Config

# Common configuration used across all environments
config :carrier, Carrier,
  hostname: "https://us-street.api.smarty.com/street-address"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
