# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :my_app,
  ecto_repos: [App.Repo]

# Configures the endpoint
config :my_app, Web.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "B73wtO2ZUJVV11ZUjpGCSjT1hiZTdrCS6wCZEqs+PCR7mtVIVh+KnkqnznJfiD3/",
  render_errors: [view: Web.ErrorView, accepts: ~w(json)],
  pubsub: [name: App.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Guardian config
config :my_app, Web.Guardian,
  issuer: "myApp",
  secret_key: "7O67/ngimtUReRqq9J9E1iitobPYnfKtW4J713FFKUupunA3Yw52vhBmj488upFF"

# Arc config
config :arc,
  storage: Arc.Storage.Local

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
