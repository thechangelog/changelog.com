import Config
# TODO: consider converting to Config.Provider:
# https://hexdocs.pm/elixir/Config.Provider.html
Code.require_file("docker_secret.exs", "config")

config :changelog,
  env: :prod,
  ecto_repos: [Changelog.Repo],
  buffer_token: DockerSecret.get("BUFFER_TOKEN_2"),
  github_api_token: DockerSecret.get("GITHUB_API_TOKEN2"),
  cm_api_token: Base.encode64("#{DockerSecret.get("CM_API_TOKEN")}:x"),
  slack_invite_api_token: DockerSecret.get("SLACK_INVITE_API_TOKEN"),
  slack_app_api_token: DockerSecret.get("SLACK_APP_API_TOKEN")

config :changelog, ChangelogWeb.Endpoint,
  http: [port: String.to_integer(System.fetch_env!("PORT"))],
  server: true,
  url: [scheme: (System.get_env("URL_SCHEME") || "https"), host: (System.get_env("URL_HOST") || "changelog.com"), port: (System.get_env("URL_PORT") || 443)],
  force_ssl: [
    rewrite_on: [:x_forwarded_proto],
    exclude: ["127.0.0.1", "localhost", "changelog.localhost"]
  ],
  secret_key_base: DockerSecret.get("SECRET_KEY_BASE"),
  static_url: [scheme: (System.get_env("URL_SCHEME") || "https"), host: (System.get_env("URL_STATIC_HOST") || "cdn.changelog.com"), port: (System.get_env("URL_PORT") || 443)],
  cache_static_manifest: "priv/static/cache_manifest.json"

config :logger,
  level: :info
# config :logger, :console, level: :debug, format: "[$level] $message\n"

config :arc,
  storage_dir: "/uploads"

config :changelog, Changelog.Repo,
  url: DockerSecret.get("DB_URL"),
  adapter: Ecto.Adapters.Postgres,
  pool_size: 20,
  timeout: 60000

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

config :ex_aws,
  access_key_id: DockerSecret.get("AWS_ACCESS_KEY_ID"),
  secret_access_key: DockerSecret.get("AWS_SECRET_ACCESS_KEY")

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: DockerSecret.get("GITHUB_CLIENT_ID"),
  client_secret: DockerSecret.get("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Twitter.OAuth,
  consumer_key: DockerSecret.get("TWITTER_CONSUMER_KEY"),
  consumer_secret: DockerSecret.get("TWITTER_CONSUMER_SECRET")

config :algolia,
  application_id: DockerSecret.get("ALGOLIA_APPLICATION_ID"),
  api_key: DockerSecret.get("ALGOLIA_API_KEY")
