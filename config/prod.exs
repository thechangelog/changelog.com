use Mix.Config

config :changelog, ChangelogWeb.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "changelog.com", port: 443],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  static_url: [scheme: "https", host: "cdn.changelog.com", port: 443],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info
# config :logger, :console, level: :debug, format: "[$level] $message\n"

config :arc,
  storage_dir: "/uploads"

config :changelog, Changelog.Repo,
  url: {:system, "DB_URL"},
  adapter: Ecto.Adapters.Postgres,
  pool_size: 20

config :changelog, Changelog.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.api.createsend.com",
  port: 587,
  username: {:system, "CM_SMTP_TOKEN"},
  password: {:system, "CM_SMTP_TOKEN"}

config :changelog, Changelog.CalendarService,
  adapter: Changelog.Services.GoogleCalendarService,
  google_calendar_id: {:system, "GOOGLE_CALENDAR_ID"}

config :changelog, Changelog.Scheduler,
  global: true,
  timezone: "US/Central",
  jobs: [
    {"0 4 * * *", {Changelog.Stats, :process, []}},
    {"0 3 * * *", {Changelog.Slack.Tasks, :import_member_ids, []}},
    {"* * * * *", {Changelog.NewsQueue, :publish, []}}
  ]

config :rollbax,
  access_token: {:system, "ROLLBAR_ACCESS_TOKEN"},
  environment: "production"
