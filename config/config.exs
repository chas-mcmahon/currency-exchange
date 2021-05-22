# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :currency_exchange, fixer_api_key: System.get_env("FIXER_API_KEY")

config :currency_exchange,
  ecto_repos: [CurrencyExchange.Repo]

# Configures the endpoint
config :currency_exchange, CurrencyExchangeWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "iuRJu3Ld5zHXcFYSOh4rvbYiIf8yVXYeG5M5YYFKcyLYny/AIOB6UqmfFF30yMKk",
  render_errors: [view: CurrencyExchangeWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: CurrencyExchange.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
