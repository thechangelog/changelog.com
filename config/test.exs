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

# Configure CalendarService
config :changelog, Changelog.CalendarService,
  adapter: Changelog.CalendarService,
  google_calendar_id: "GOOGLE_CALENDAR_ID"

# Configure your database
config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "changelog_test",
  pool: Ecto.Adapters.SQL.Sandbox

config :arc,
  storage_dir: "priv/uploads"

config :rollbax,
  access_token: "",
  environment: "test",
  enabled: false
