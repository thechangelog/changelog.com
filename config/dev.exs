use Mix.Config

config :changelog, ChangelogWeb.Endpoint,
  url: [host: System.get_env("HOST") || "localhost"],
  http: [
    port: 4000
  ],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [
    yarn: ["start", cd: Path.expand("../assets", __DIR__)]
  ]

# Sometimes we need HTTPS, like when futzing with captchas
if System.get_env("HTTPS") == "true" do
  config :changelog, ChangelogWeb.Endpoint,
    https: [
      port: 4001,
      cipher_suite: :strong,
      certfile: "priv/cert/selfsigned.pem",
      keyfile: "priv/cert/selfsigned_key.pem"
    ]
end

# Watch static and templates for browser reloading.
config :changelog, ChangelogWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{lib/changelog_web/(live|views)/.*(ex)$},
      ~r{lib/changelog_web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: SecretOrEnv.get("DB_NAME", "changelog_dev"),
  hostname: SecretOrEnv.get("DB_HOST", "localhost"),
  username: SecretOrEnv.get("DB_USER", "postgres"),
  password: SecretOrEnv.get("DB_PASS", "postgres"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :rollbax,
  access_token: "",
  environment: "development",
  enabled: :log

config :changelog, Changelog.PromEx,
  manual_metrics_start_delay: :no_delay,
  drop_metrics_groups: [],
  grafana: [
    host: SecretOrEnv.get("GRAFANA_URL", "http://localhost:3000"),
    # This API Key will need to be created manually, most probably via http://localhost:3000/org/apikeys
    auth_token: SecretOrEnv.get("GRAFANA_API_TOKEN"),
    # This can default to Prometheus, PromEx uses this lowercase value for the built-in dashboards
    datasource_id: SecretOrEnv.get("GRAFANA_DATASOURCE_ID", "prometheus")
  ],
  metrics_server: :disabled
