use Mix.Config

config :changelog,
  buffer_token: SecretOrEnv.get("BUFFER_TOKEN"),
  github_api_token: SecretOrEnv.get("GITHUB_API_TOKEN"),
  hcaptcha_secret_key: SecretOrEnv.get("HCAPTCHA_SECRET_KEY"),
  hn_user: SecretOrEnv.get("HN_USER"),
  hn_pass: SecretOrEnv.get("HN_PASS"),
  cm_api_token: Base.encode64("#{SecretOrEnv.get("CM_API_TOKEN")}:x"),
  slack_invite_api_token: SecretOrEnv.get("SLACK_INVITE_API_TOKEN"),
  slack_app_api_token: SecretOrEnv.get("SLACK_APP_API_TOKEN"),
  plusplus_slug: SecretOrEnv.get("PLUSPLUS_SLUG")

config :changelog, ChangelogWeb.Endpoint,
  http: [port: System.get_env("HTTP_PORT", "4000")],
  url: [
    scheme: System.get_env("URL_SCHEME", "https"),
    host: System.get_env("URL_HOST", "changelog.com"),
    port: System.get_env("URL_PORT", "443")
  ],
  force_ssl: [
    rewrite_on: [:x_forwarded_proto],
    exclude: String.split(System.get_env("FORCE_SSL_EXCLUDE_HOSTS", "127.0.0.1, localhost"))
  ],
  secret_key_base: SecretOrEnv.get("SECRET_KEY_BASE"),
  static_url: [
    scheme: System.get_env("STATIC_URL_SCHEME", "https"),
    host: System.get_env("STATIC_URL_HOST", "cdn.changelog.com"),
    port: System.get_env("STATIC_URL_PORT", "443")
  ],
  cache_static_manifest: "priv/static/cache_manifest.json"

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

# config :logger, :console, level: :debug, format: "[$level] $message\n"

config :arc,
  storage_dir: System.get_env("UPLOADS_PATH", "/uploads")

config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME", "changelog"),
  hostname: System.get_env("DB_HOST", "db"),
  password: SecretOrEnv.get("DB_PASS"),
  pool_size: 40,
  timeout: 60000,
  username: System.get_env("DB_USER", "postgres")

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
    host: System.get_env("GRAFANA_URL"),
    auth_token: SecretOrEnv.get("GRAFANA_API_KEY"),
    datasource_id: System.get_env("GRAFANA_DATASOURCE_ID", "Prometheus"),
    annotate_app_lifecycle: true
  ],
  metrics_server: :disabled,
  prometheus_bearer_token: SecretOrEnv.get("PROMETHEUS_BEARER_TOKEN_PROM_EX")

config :shopify,
  shop_name: "changelog",
  api_key: SecretOrEnv.get("SHOPIFY_API_KEY"),
  password: SecretOrEnv.get("SHOPIFY_API_PASSWORD")

config :ex_aws,
  access_key_id: SecretOrEnv.get("AWS_ACCESS_KEY_ID"),
  secret_access_key: SecretOrEnv.get("AWS_SECRET_ACCESS_KEY")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: SecretOrEnv.get("GITHUB_CLIENT_ID"),
  client_secret: SecretOrEnv.get("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Twitter.OAuth,
  consumer_key: SecretOrEnv.get("TWITTER_CONSUMER_KEY"),
  consumer_secret: SecretOrEnv.get("TWITTER_CONSUMER_SECRET")

config :algolia,
  application_id: SecretOrEnv.get("ALGOLIA_APPLICATION_ID"),
  api_key: SecretOrEnv.get("ALGOLIA_API_KEY")
