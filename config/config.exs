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
  pubsub_server: Changelog.PubSub,
  live_view: [signing_salt: "+GzuQhsbhBJIqc4ctHLGjo+D2ZohVqNW"]

config :changelog,
  buffer_token: SecretOrEnv.get("BUFFER_TOKEN"),
  cm_api_token: Base.encode64("#{SecretOrEnv.get("CM_API_TOKEN")}:x"),
  fastly_token: SecretOrEnv.get("FASTLY_TOKEN"),
  github_api_token: SecretOrEnv.get("GITHUB_API_TOKEN"),
  hn_user: SecretOrEnv.get("HN_USER"),
  hn_pass: SecretOrEnv.get("HN_PASS"),
  mastodon_client_id: SecretOrEnv.get("MASTODON_CLIENT_ID"),
  mastodon_client_secret: SecretOrEnv.get("MASTODON_CLIENT_SECRET"),
  mastodon_api_token: SecretOrEnv.get("MASTODON_API_TOKEN"),
  plusplus_slug: SecretOrEnv.get("PLUSPLUS_SLUG"),
  plusplus_url: "https://changelog.supercast.com",
  turnstile_secret_key: SecretOrEnv.get("TURNSTILE_SECRET_KEY"),
  slack_invite_api_token: SecretOrEnv.get("SLACK_INVITE_API_TOKEN"),
  slack_app_api_token: SecretOrEnv.get("SLACK_APP_API_TOKEN"),
  typesense_url: SecretOrEnv.get("TYPESENSE_URL"),
  typesense_api_key: SecretOrEnv.get("TYPESENSE_API_KEY"),
  # 60 = one minute, 3600 = one hour, 86,400 = one day, 604,800 = one week, 31,536,000 = one year
  cdn_cache_control_s3: SecretOrEnv.get("CDN_CACHE_CONTROL_S3", "max-age=31536000, stale-while-revalidate=3600, stale-if-error=86400"),
  cdn_cache_control_app: SecretOrEnv.get("CDN_CACHE_CONTROL_APP", "max-age=60, stale-while-revalidate=60, stale-if-error=604800"),
  ecto_repos: [Changelog.Repo]

config :changelog, Oban,
  repo: Changelog.Repo,
  queues: [audio_updater: 2, scheduled: 5, email: 5, feeds: 5],
  plugins: [Oban.Plugins.Pruner]

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
  access_key_id: SecretOrEnv.get("R2_ACCESS_KEY_ID"),
  secret_access_key: SecretOrEnv.get("R2_SECRET_ACCESS_KEY")

config :ex_aws, :s3,
  host: SecretOrEnv.get("R2_API_HOST")

config :ex_aws, :hackney_opts, recv_timeout: 300_000

config :waffle,
  storage: Waffle.Storage.S3,
  version_timeout: 30_000,
  bucket: SecretOrEnv.get("R2_ASSETS_BUCKET")

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

config :opentelemetry,
  resource: [
    service: [
      name: "changelog",
      namespace: "#{config_env()}",
    ],
    user: [
      name: System.get_env("USER"),
    ],
  ],
  span_processor: :batch,
  traces_exporter: :none

if System.get_env("HONEYCOMB_API_KEY") do
  config :opentelemetry, traces_exporter: :otlp
  config :opentelemetry_exporter,
    otlp_protocol: :http_protobuf,
    otlp_compression: :gzip,
    otlp_endpoint: "https://api.honeycomb.io:443",
    otlp_headers: [
      {"x-honeycomb-team", SecretOrEnv.get("HONEYCOMB_API_KEY")},
      {"x-honeycomb-dataset", "changelog_opentelemetry"}
    ]
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
