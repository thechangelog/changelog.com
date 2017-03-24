use Mix.Config

config :changelog, Changelog.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "changelog.com", port: 443],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  static_url: [scheme: "https", host: "cdn.changelog.com", port: 443],
  cache_static_manifest: "priv/static/manifest.json"

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

config :quantum, :changelog,
  cron: [
    "0 11 * * *": {Changelog.Stats, :process},
    "0 10 * * *": {Changelog.Slack.Tasks, :import_member_ids}
  ],
  global?: true
