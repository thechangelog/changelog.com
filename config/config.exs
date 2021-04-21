# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :changelog, ChangelogWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "PABstVJCyPEcRByCU8tmSZjv0UfoV+UeBlXNRigy4ba221RzqfN82qwsKvA5bJzi",
  render_errors: [accepts: ~w(html json)],
  pubsub_server: Changelog.PubSub,
  cdn_static_cache:
    System.get_env(
      "CDN_STATIC_CACHE",
      "max-age=#{3600 * 24 * 7}, stale-while-revalidate=3600, stale-if-error=#{3600 * 24 * 7}"
    ),
  cdn_app_cache:
    System.get_env(
      "CDN_APP_CACHE",
      "max-age=60, stale-while-revalidate=60, stale-if-error=#{3600 * 24 * 7}"
    )

config :changelog,
  ecto_repos: [Changelog.Repo]

config :changelog, Oban,
  repo: Changelog.Repo,
  plugins: [Oban.Plugins.Pruner, Oban.Plugins.Stager],
  queues: [comment_notifier: 10]

config :changelog, Changelog.Mailer, adapter: Bamboo.LocalAdapter

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :arc,
  storage_dir: System.get_env("UPLOADS_PATH", "priv/uploads")

config :phoenix, :json_library, Jason

config :phoenix, :format_encoders, ics: ICalendar

config :phoenix, :generators,
  migration: true,
  binary_id: false

config :scrivener_html,
  routes_helper: ChangelogWeb.Router.Helpers,
  view_style: :semantic

config :mime, :types, %{"application/javascript" => ["js"], "application/xml" => ["xml"]}

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]},
    twitter: {Ueberauth.Strategy.Twitter, []}
  ]

config :sentry,
  dsn: "https://2b1aed8f16f5404cb2bc79b855f2f92d@o546963.ingest.sentry.io/5668962",
  included_environments: [:prod],
  environment_name: Mix.env(),
  filter: Changelog.Sentry.EventFilter

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
