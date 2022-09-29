# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

config :changelog, ChangelogWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    SecretOrEnv.get(
      "SECRET_KEY_BASE",
      "PABstVJCyPEcRByCU8tmSZjv0UfoV+UeBlXNRigy4ba221RzqfN82qwsKvA5bJzi"
    ),
  render_errors: [view: ChangelogWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Changelog.PubSub

config :changelog,
  buffer_token: SecretOrEnv.get("BUFFER_TOKEN"),
  cm_api_token: Base.encode64("#{SecretOrEnv.get("CM_API_TOKEN")}:x"),
  github_api_token: SecretOrEnv.get("GITHUB_API_TOKEN"),
  hn_user: SecretOrEnv.get("HN_USER"),
  hn_pass: SecretOrEnv.get("HN_PASS"),
  notion_api_token: SecretOrEnv.get("NOTION_API_TOKEN"),
  plusplus_slug: SecretOrEnv.get("PLUSPLUS_SLUG"),
  plusplus_url: "https://changelog.supercast.com",
  recaptcha_secret_key: SecretOrEnv.get("RECAPTCHA_SECRET_KEY"),
  turnstile_secret_key: SecretOrEnv.get("TURNSTILE_SECRET_KEY"),
  slack_invite_api_token: SecretOrEnv.get("SLACK_INVITE_API_TOKEN"),
  slack_app_api_token: SecretOrEnv.get("SLACK_APP_API_TOKEN"),
  # 60 = one minute, 3600 = one hour, 86,400 = one day, 604,800 = one week, 31,536,000 = one year
  cdn_cache_control_s3: SecretOrEnv.get("CDN_CACHE_CONTROL_S3", "max-age=31536000, stale-while-revalidate=3600, stale-if-error=86400"),
  cdn_cache_control_app: SecretOrEnv.get("CDN_CACHE_CONTROL_APP", "max-age=60, stale-while-revalidate=60, stale-if-error=604800"),
  ecto_repos: [Changelog.Repo]

config :changelog, Oban,
  repo: Changelog.Repo,
  queues: [comment_notifier: 10, audio_updater: 10, scheduled: 5],
  plugins: [Oban.Plugins.Pruner, Oban.Plugins.Stager]

config :changelog, Changelog.Mailer, adapter: Bamboo.LocalAdapter

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :phoenix, :format_encoders, ics: ICalendar

config :phoenix, :generators,
  migration: true,
  binary_id: false

config :scrivener_html,
  routes_helper: ChangelogWeb.Router.Helpers,
  view_style: :semantic

config :mime, :types, %{"application/javascript" => ["js"], "application/xml" => ["xml"]}

config :shopify,
  shop_name: "changelog",
  api_key: SecretOrEnv.get("SHOPIFY_API_KEY"),
  password: SecretOrEnv.get("SHOPIFY_API_PASSWORD")

config :ex_aws,
  access_key_id: SecretOrEnv.get("AWS_ACCESS_KEY_ID"),
  secret_access_key: SecretOrEnv.get("AWS_SECRET_ACCESS_KEY"),
  region: SecretOrEnv.get("AWS_REGION")

config :ex_aws, :hackney_opts, recv_timeout: 300_000

config :waffle,
  storage: Waffle.Storage.S3,
  version_timeout: 30_000,
  bucket: SecretOrEnv.get("AWS_ASSETS_BUCKET")

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]},
    twitter: {Ueberauth.Strategy.Twitter, []}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: SecretOrEnv.get("GITHUB_CLIENT_ID"),
  client_secret: SecretOrEnv.get("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Twitter.OAuth,
  consumer_key: SecretOrEnv.get("TWITTER_CONSUMER_KEY"),
  consumer_secret: SecretOrEnv.get("TWITTER_CONSUMER_SECRET")

config :algolia,
  application_id: SecretOrEnv.get("ALGOLIA_APPLICATION_ID"),
  api_key: SecretOrEnv.get("ALGOLIA_API_KEY")

config :sentry,
  dsn: "https://2b1aed8f16f5404cb2bc79b855f2f92d@o546963.ingest.sentry.io/5668962",
  included_environments: [:prod],
  environment_name: Mix.env(),
  filter: Changelog.Sentry.EventFilter

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
