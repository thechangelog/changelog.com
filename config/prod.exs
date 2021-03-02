use Mix.Config

config :changelog, ChangelogWeb.Endpoint,
  http: [port: System.get_env("PORT")],
  url: [
    scheme: System.get_env("URL_SCHEME") || "https",
    host: System.get_env("URL_HOST") || "changelog.com",
    port: System.get_env("URL_PORT") || 443
  ],
  force_ssl: [
    rewrite_on: [:x_forwarded_proto],
    exclude: ["127.0.0.1", "localhost", "changelog.localhost"]
  ],
  secret_key_base: SecretOrEnv.get("SECRET_KEY_BASE"),
  static_url: [
    scheme: SecretOrEnv.get("URL_SCHEME", "https"),
    host: SecretOrEnv.get("URL_STATIC_HOST", "cdn.changelog.com"),
    port: SecretOrEnv.get("URL_PORT", 443)
  ],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger, level: :info
# config :logger, :console, level: :debug, format: "[$level] $message\n"

config :arc,
  storage_dir: SecretOrEnv.get("UPLOADS_PATH", "/uploads")

config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: SecretOrEnv.get("DB_NAME", "changelog"),
  hostname: SecretOrEnv.get("DB_HOST", "db"),
  password: SecretOrEnv.get("DB_PASS"),
  pool_size: 40,
  timeout: 60000,
  username: SecretOrEnv.get("DB_USER", "postgres")

config :changelog, Changelog.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.api.createsend.com",
  port: 587,
  username: SecretOrEnv.get("CM_SMTP_TOKEN"),
  password: SecretOrEnv.get("CM_SMTP_TOKEN")

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :changelog, Changelog.Scheduler,
  global: true,
  timezone: "US/Central",
  jobs: [
    {"0 4 * * *", {Changelog.Stats, :process, []}},
    {"0 3 * * *", {Changelog.Slack.Tasks, :import_member_ids, []}},
    {"* * * * *", {Changelog.NewsQueue, :publish, []}}
  ]

config :rollbax,
  access_token: SecretOrEnv.get("ROLLBAR_ACCESS_TOKEN"),
  environment: "production"

config :changelog, Changelog.PromEx,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: [
    host: SecretOrEnv.get("GRAFANA_URL"),
    auth_token: SecretOrEnv.get("GRAFANA_API_KEY"),
    datasource_id: SecretOrEnv.get("GRAFANA_DATASOURCE_ID", "Prometheus"),
    annotate_app_lifecycle: true
  ],
  metrics_server: :disabled,
  prometheus_bearer_token: SecretOrEnv.get("PROMETHEUS_BEARER_TOKEN_PROM_EX")
