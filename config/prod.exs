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

# Serve Waffle static assets from our CDN, usually cdn.changelog.com
config :waffle,
  asset_host: "https://#{static_url_host}"

config :sentry,
  dsn: "https://2b1aed8f16f5404cb2bc79b855f2f92d@o546963.ingest.sentry.io/5668962",
  environment_name: Mix.env(),
  filter: Changelog.Sentry.EventFilter

config :logger,
  level: :info,
  backends: [:console, Sentry.LoggerBackend]

config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME", "changelog"),
  hostname: System.get_env("DB_HOST", "db"),
  username: System.get_env("DB_USER", "postgres"),
  ssl: true,
  ssl_opts: [
    # The cacertfile value implies Ubuntu,
    # which is what we use when building the prod container image
    cacertfile: "/etc/ssl/certs/ca-certificates.crt",
    verify: :verify_peer,
    server_name_indication: String.to_charlist(System.get_env("DB_HOST", "db")),
    customize_hostname_check: [
      match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
    ]
  ],
  password: SecretOrEnv.get("DB_PASS"),
  timeout: 60000,
  pool_size: 40

config :changelog, Changelog.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.api.createsend.com",
  port: 587,
  username: SecretOrEnv.get("CM_SMTP_TOKEN"),
  password: SecretOrEnv.get("CM_SMTP_TOKEN")

config :elixir,
  :time_zone_database, Tzdata.TimeZoneDatabase

config :changelog, Oban,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 43_200}, # 12 hours
    {Oban.Plugins.Cron,
     timezone: "US/Central",
     crontab: [
       {"00 3 * * *", Changelog.ObanWorkers.SlackImporter},
       {"30 3 * * *", Changelog.ObanWorkers.Bouncer},
       {"00 4 * * *", Changelog.ObanWorkers.StatsProcessor},
       {"* * * * *", Changelog.ObanWorkers.NewsPublisher},
       {"15 * * * *", Changelog.ObanWorkers.SmokeTester}
     ]}
  ]
