# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
import Config

config :changelog, ChangelogWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base:
    System.get_env(
      "SECRET_KEY_BASE",
      "PABstVJCyPEcRByCU8tmSZjv0UfoV+UeBlXNRigy4ba221RzqfN82qwsKvA5bJzi"
    ),
  render_errors: [view: ChangelogWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Changelog.PubSub,
  live_view: [signing_salt: "+GzuQhsbhBJIqc4ctHLGjo+D2ZohVqNW"]

config :changelog,
  buffer_token: System.get_env("BUFFER_TOKEN"),
  cm_api_token: Base.encode64("#{System.get_env("CM_API_TOKEN")}:x"),
  fastly_token: System.get_env("FASTLY_TOKEN"),
  github_api_token: System.get_env("GITHUB_API_TOKEN"),
  bsky_user: System.get_env("BSKY_USER"),
  bsky_pass: System.get_env("BSKY_PASS"),
  hn_user: System.get_env("HN_USER"),
  hn_pass: System.get_env("HN_PASS"),
  mastodon_client_id: System.get_env("MASTODON_CLIENT_ID"),
  mastodon_client_secret: System.get_env("MASTODON_CLIENT_SECRET"),
  mastodon_api_token: System.get_env("MASTODON_API_TOKEN"),
  plusplus_slug: System.get_env("PLUSPLUS_SLUG"),
  plusplus_url: "https://changelog.supercast.com",
  turnstile_secret_key: System.get_env("TURNSTILE_SECRET_KEY"),
  slack_invite_api_token: System.get_env("SLACK_INVITE_API_TOKEN"),
  slack_app_api_token: System.get_env("SLACK_APP_API_TOKEN"),
  snap_token: System.get_env("SNAP_TOKEN"),
  typesense_url: System.get_env("TYPESENSE_URL"),
  typesense_api_key: System.get_env("TYPESENSE_API_KEY"),
  zulip_url: "https://changelog.zulipchat.com",
  zulip_admin_user: System.get_env("ZULIP_ADMIN_USER"),
  zulip_admin_api_key: System.get_env("ZULIP_ADMIN_API_KEY"),
  zulip_bot_user: System.get_env("ZULIP_BOT_USER"),
  zulip_bot_api_key: System.get_env("ZULIP_BOT_API_KEY"),
  # 60 = one minute, 3600 = one hour, 86,400 = one day, 604,800 = one week, 31,536,000 = one year
  cdn_cache_control_s3:
    System.get_env(
      "CDN_CACHE_CONTROL_S3",
      "max-age=31536000, stale-while-revalidate=3600, stale-if-error=86400"
    ),
  cdn_cache_control_app:
    System.get_env(
      "CDN_CACHE_CONTROL_APP",
      "max-age=60, stale-while-revalidate=60, stale-if-error=604800"
    ),
  ecto_repos: [Changelog.Repo]

config :changelog, Oban,
  repo: Changelog.Repo,
  queues: [default: 1, audio_updater: 2, scheduled: 2, email: 6, feeds: 5],
  plugins: [Oban.Plugins.Pruner]

config :changelog, Changelog.Mailer, adapter: Swoosh.Adapters.Local

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

config :phoenix, :format_encoders, ics: ICalendar

config :phoenix, :generators,
  migration: true,
  binary_id: false

config :mime, :types, %{"application/javascript" => ["js"], "application/xml" => ["xml"]}

config :shopify,
  shop_name: "changelog",
  api_key: System.get_env("SHOPIFY_API_KEY"),
  password: System.get_env("SHOPIFY_API_PASSWORD")

config :ex_aws,
  access_key_id: System.get_env("R2_ACCESS_KEY_ID"),
  secret_access_key: System.get_env("R2_SECRET_ACCESS_KEY")

config :ex_aws, :s3, host: System.get_env("R2_API_HOST")

config :ex_aws, :hackney_opts, recv_timeout: 300_000

config :waffle,
  storage: Waffle.Storage.S3,
  version_timeout: 30_000,
  bucket: System.get_env("R2_ASSETS_BUCKET")

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]},
    twitter: {Ueberauth.Strategy.Twitter, []}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :stripity_stripe,
  api_key: System.get_env("STRIPE_SECRET"),
  signing_secret: System.get_env("STRIPE_WEBHOOK_SECRET")

config :opentelemetry,
  resource: [
    service: [
      name: "changelog",
      namespace: "#{config_env()}"
    ],
    user: [
      name: System.get_env("USER")
    ]
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
      {"x-honeycomb-team", System.get_env("HONEYCOMB_API_KEY")},
      {"x-honeycomb-dataset", "changelog_opentelemetry"}
    ]
end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
