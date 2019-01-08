# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config
Code.load_file("config/docker_secret.exs")

config :changelog, ChangelogWeb.Endpoint,
  url: [host: "localhost"],
  static_url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "PABstVJCyPEcRByCU8tmSZjv0UfoV+UeBlXNRigy4ba221RzqfN82qwsKvA5bJzi",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Changelog.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :changelog,
  ecto_repos: [Changelog.Repo],
  buffer_token: DockerSecret.get("BUFFER_TOKEN"),
  github_api_token: DockerSecret.get("GITHUB_API_TOKEN"),
  cm_api_token: Base.encode64("#{DockerSecret.get("CM_API_TOKEN")}:x"),
  slack_invite_api_token: DockerSecret.get("SLACK_APP_API_TOKEN"),
  slack_app_api_token: DockerSecret.get("SLACK_APP_API_TOKEN")

config :changelog, Changelog.Mailer,
  adapter: Bamboo.LocalAdapter

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :generators,
  migration: true,
  binary_id: false

config :scrivener_html,
  routes_helper: ChangelogWeb.Router.Helpers,
  view_style: :semantic

config :ex_aws,
  access_key_id: DockerSecret.get("AWS_ACCESS_KEY_ID"),
  secret_access_key: DockerSecret.get("AWS_SECRET_ACCESS_KEY")

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user:email"]},
    twitter: {Ueberauth.Strategy.Twitter, []}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: DockerSecret.get("GITHUB_CLIENT_ID"),
  client_secret: DockerSecret.get("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth.Strategy.Twitter.OAuth,
  consumer_key: DockerSecret.get("TWITTER_CONSUMER_KEY"),
  consumer_secret: DockerSecret.get("TWITTER_CONSUMER_SECRET")

config :algolia,
  application_id: DockerSecret.get("ALGOLIA_APPLICATION_ID"),
  api_key: DockerSecret.get("ALGOLIA_API_KEY")

config :plug_ets_cache,
  db_name: :response_cache,
  ttl_check: 1,
  ttl: 60

config :mime, :types, %{"application/javascript" => ["js"], "application/xml" => ["xml"]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
