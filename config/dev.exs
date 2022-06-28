import Config

config :changelog, ChangelogWeb.Endpoint,
  http: [port: 4000],
  url: [host: System.get_env("HOST", "localhost")],
  check_origin: false,
  static_url: [path: "/static"],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [
    yarn: ["start", cd: Path.expand("../assets", __DIR__)]
  ],
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{lib/changelog_web/(live|views)/.*(ex)$},
      ~r{lib/changelog_web/templates/.*(eex)$}
    ]
  ]

# Sometimes we need HTTPS, like when futzing with captchas
if System.get_env("HTTPS") do
  config :changelog, ChangelogWeb.Endpoint,
    https: [
      port: 4001,
      cipher_suite: :strong,
      certfile: "priv/cert/selfsigned.pem",
      keyfile: "priv/cert/selfsigned_key.pem"
    ]
end

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

# in dev route direct to S3, in prod route through CDN
config :waffle, asset_host: SecretOrEnv.get("AWS_UPLOADS_HOST")

config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME", "changelog_dev"),
  hostname: System.get_env("DB_HOST", "localhost"),
  username: System.get_env("DB_USER", "postgres"),
  password: System.get_env("DB_PASS", "postgres"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :changelog, Changelog.PromEx,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: [
    host: System.get_env("GRAFANA_URL", "http://localhost:3000"),
    # This API Key will need to be created manually, most probably via http://localhost:3000/org/apikeys
    auth_token: SecretOrEnv.get("GRAFANA_API_KEY"),
    # This can default to Prometheus, PromEx uses this lowercase value for the built-in dashboards
    datasource_id: System.get_env("GRAFANA_DATASOURCE_ID", "prometheus"),
    annotate_app_lifecycle: true
  ],
  metrics_server: :disabled,
  prometheus_bearer_token: SecretOrEnv.get("PROMETHEUS_BEARER_TOKEN_PROM_EX")
