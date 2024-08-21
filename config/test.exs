import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :changelog, ChangelogWeb.Endpoint,
  http: [port: 4001, ip: {0, 0, 0, 0, 0, 0, 0, 0}],
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

config :changelog, Changelog.Mailer, adapter: Swoosh.Adapters.Test

# Configure your database
config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME", "changelog_test"),
  hostname: System.get_env("DB_HOST", "localhost"),
  password: System.get_env("DB_PASS", "postgres"),
  pool: Ecto.Adapters.SQL.Sandbox,
  username: System.get_env("DB_USER", "postgres")

config :changelog, Oban, testing: :manual
