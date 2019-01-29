use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :changelog, ChangelogWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configures Bamboo
config :changelog, Changelog.Mailer,
  adapter: Bamboo.TestAdapter

# Configure your database
config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  pool: Ecto.Adapters.SQL.Sandbox,
  url: (System.get_env("DB_URL") || "ecto://postgres:postgres@localhost:5432/changelog_test")

config :arc,
  storage_dir: "priv/uploads"

config :rollbax,
  access_token: "",
  environment: "test",
  enabled: :log
