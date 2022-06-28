import Config

static_url_host = System.get_env("STATIC_URL_HOST", "cdn.changelog.com")

config :changelog, ChangelogWeb.Endpoint,
  http: [port: System.get_env("HTTP_PORT", "4000")],
  url: [
    scheme: System.get_env("URL_SCHEME", "https"),
    host: System.get_env("URL_HOST", "changelog.com"),
    port: System.get_env("URL_PORT", "443")
  ],
  static_url: [
    scheme: System.get_env("STATIC_URL_SCHEME", "https"),
    host: static_url_host,
    port: System.get_env("STATIC_URL_PORT", "443"),
    path: "/static"
  ],
  cache_static_manifest: "priv/static/cache_manifest.json",
  # we don't need vsn=?d because Plug.Static doesn't serve static assets in prod
  cache_manifest_skip_vsn: true

# in prod we point waffle to the CDN, just like we tell our own endpoint
config :waffle, asset_host: "https://#{static_url_host}"

if System.get_env("HTTPS") do
  config :changelog, ChangelogWeb.Endpoint,
    https: [
      port: System.get_env("HTTPS_PORT", "443"),
      cipher_suite: :strong,
      otp_app: :changelog,
      certfile: System.get_env("HTTPS_CERTFILE"),
      keyfile: System.get_env("HTTPS_KEYFILE")
    ]
end

config :logger,
  level: :info,
  backends: [:console, Sentry.LoggerBackend]

config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME", "changelog"),
  hostname: System.get_env("DB_HOST", "db"),
  password: SecretOrEnv.get("DB_PASS"),
  pool_size: 40,
  timeout: 60000,
  username: System.get_env("DB_USER", "postgres")

if System.get_env("FLY_APP_NAME") do
config :changelog, Changelog.Repo,
  socket_options: [:inet6]
end

config :changelog, Changelog.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.api.createsend.com",
  port: 587,
  username: SecretOrEnv.get("CM_SMTP_TOKEN"),
  password: SecretOrEnv.get("CM_SMTP_TOKEN")

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :changelog, Oban,
  plugins: [
    Oban.Plugins.Pruner,
    Oban.Plugins.Stager,
    {Oban.Plugins.Cron,
     timezone: "US/Central",
     crontab: [
       {"0 3 * * *", Changelog.ObanWorkers.SlackImporter},
       {"0 4 * * *", Changelog.ObanWorkers.StatsProcessor},
       {"0 5 * * *", Changelog.ObanWorkers.NotionUpdater},
       {"* * * * *", Changelog.ObanWorkers.NewsPublisher}
     ]}
  ]

config :changelog, Changelog.PromEx,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: [
    host: System.get_env("GRAFANA_URL"),
    auth_token: SecretOrEnv.get("GRAFANA_API_KEY"),
    datasource_id: System.get_env("GRAFANA_DATASOURCE_ID", "Prometheus"),
    annotate_app_lifecycle: true
  ],
  metrics_server: :disabled,
  prometheus_bearer_token: SecretOrEnv.get("PROMETHEUS_BEARER_TOKEN_PROM_EX")
