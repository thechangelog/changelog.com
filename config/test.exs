use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :changelog, ChangelogWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configures Bamboo
config :changelog, Changelog.Mailer, adapter: Bamboo.TestAdapter

# Configure your database
config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: SecretOrEnv.get("DB_NAME", "changelog_test"),
  hostname: SecretOrEnv.get("DB_HOST", "localhost"),
  password: SecretOrEnv.get("DB_PASS", "postgres"),
  pool: Ecto.Adapters.SQL.Sandbox,
  username: SecretOrEnv.get("DB_USER", "postgres")

config :changelog, Oban,
  crontab: false,
  queues: false,
  plugins: false

config :rollbax,
  access_token: "",
  environment: "test",
  enabled: :log
