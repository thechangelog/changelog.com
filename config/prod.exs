use Mix.Config

config :changelog, ChangelogWeb.Endpoint,
  http: [port: System.get_env("PORT")],
  url: [scheme: (System.get_env("URL_SCHEME") || "https"), host: (System.get_env("URL_HOST") || "changelog.com"), port: (System.get_env("URL_PORT") || 443)],
  secret_key_base: DockerSecret.get("SECRET_KEY_BASE"),
  static_url: [scheme: (System.get_env("URL_SCHEME") || "https"), host: (System.get_env("URL_STATIC_HOST") || "cdn.changelog.com"), port: (System.get_env("URL_PORT") || 443)],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info
# config :logger, :console, level: :debug, format: "[$level] $message\n"

config :arc,
  storage_dir: "/uploads"

config :changelog, Changelog.Repo,
  url: DockerSecret.get("DB_URL"),
  adapter: Ecto.Adapters.Postgres,
  pool_size: 20

config :changelog, Changelog.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.api.createsend.com",
  port: 587,
  username: DockerSecret.get("CM_SMTP_TOKEN"),
  password: DockerSecret.get("CM_SMTP_TOKEN")

config :changelog, Changelog.Scheduler,
  global: true,
  timezone: "US/Central",
  jobs: [
    {"0 4 * * *", {Changelog.Stats, :process, []}},
    {"0 3 * * *", {Changelog.Slack.Tasks, :import_member_ids, []}},
    {"* * * * *", {Changelog.NewsQueue, :publish, []}}
  ]

config :rollbax,
  access_token: DockerSecret.get("ROLLBAR_ACCESS_TOKEN"),
  environment: "production"
