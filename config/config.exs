# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

config :changelog, Changelog.Endpoint,
  url: [host: "localhost"],
  static_url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "PABstVJCyPEcRByCU8tmSZjv0UfoV+UeBlXNRigy4ba221RzqfN82qwsKvA5bJzi",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Changelog.PubSub,
           adapter: Phoenix.PubSub.PG2]

config :changelog,
  ecto_repos: [Changelog.Repo],
  cm_api_token: Base.encode64("#{System.get_env("CM_API_TOKEN")}:x"),
  slack_api_token: System.get_env("SLACK_API_TOKEN")

config :changelog, Changelog.Mailer,
  adapter: Bamboo.LocalAdapter

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :generators,
  migration: true,
  binary_id: false

config :scrivener_html,
  routes_helper: Changelog.Router.Helpers,
  view_style: :semantic

config :ex_aws,
  access_key_id: {:system, "AWS_ACCESS_KEY_ID"},
  secret_access_key: {:system, "AWS_SECRET_ACCESS_KEY"}

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, []},
    twitter: {Ueberauth.Strategy.Twitter, []}
  ]

config :ueberauth, Ueberauth.Strategy.Github.OAuth,
  client_id: System.get_env("GITHUB_CLIENT_ID"),
  client_secret: System.get_env("GITHUB_CLIENT_SECRET")

config :ueberauth, Ueberauth,
  providers: [
    github: {Ueberauth.Strategy.Github, [default_scope: "user"]}
  ]
  
config :ueberauth, Ueberauth.Strategy.Twitter.OAuth,
  consumer_key: System.get_env("TWITTER_CONSUMER_KEY"),
  consumer_secret: System.get_env("TWITTER_CONSUMER_SECRET")

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
