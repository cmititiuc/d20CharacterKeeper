# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :d20CharacterKeeper,
  ecto_repos: [D20CharacterKeeper.Repo]

# Configures the endpoint
config :d20CharacterKeeper, D20CharacterKeeper.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "TkIj1WhwcAZmuZWzBx4hWcNCVMHz0DzQOyQIc/7Nmzw/qGoGM4skzsxZsRReXFXy",
  render_errors: [view: D20CharacterKeeper.ErrorView, accepts: ~w(html json)],
  pubsub: [name: D20CharacterKeeper.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :template_engines,
  slim: PhoenixSlime.Engine,
  slime: PhoenixSlime.Engine

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
