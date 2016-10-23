use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :d20CharacterKeeper, D20CharacterKeeper.Endpoint,
  http: [port: 4001],
  server: true

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :d20CharacterKeeper, D20CharacterKeeper.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "d20characterkeeper_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :hound, driver: "phantomjs"
