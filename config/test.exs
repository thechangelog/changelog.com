use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :changelog, Changelog.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "changelog_test",
  pool: Ecto.Adapters.SQL.Sandbox
