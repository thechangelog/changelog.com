# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config
Code.compile_file("config/secret_or_env.exs")

config :changelog, ChangelogWeb.Endpoint,
  url: [host: "localhost"],
  static_url: [host: "localhost"],
  root: Path.dirname(__DIR__),
  secret_key_base: "PABstVJCyPEcRByCU8tmSZjv0UfoV+UeBlXNRigy4ba221RzqfN82qwsKvA5bJzi",
  render_errors: [accepts: ~w(html json)],
  pubsub: [name: Changelog.PubSub, adapter: Phoenix.PubSub.PG2]

config :changelog,
  ecto_repos: [Changelog.Repo],
  buffer_token: SecretOrEnv.get("BUFFER_TOKEN_3"),
  github_api_token: SecretOrEnv.get("GITHUB_API_TOKEN2"),
  hn_user: SecretOrEnv.get("HN_USER_1"),
  hn_pass: SecretOrEnv.get("HN_PASS_1"),
  cm_api_token: Base.encode64("#{SecretOrEnv.get("CM_API_TOKEN_2")}:x"),
  slack_invite_api_token: SecretOrEnv.get("SLACK_INVITE_API_TOKEN"),
  slack_app_api_token: SecretOrEnv.get("SLACK_APP_API_TOKEN"),
  plusplus_slug: SecretOrEnv.get("PLUSPLUS_SLUG_1")

config :changelog, Changelog.Mailer, adapter: Bamboo.LocalAdapter

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :arc,
  storage_dir: SecretOrEnv.get("UPLOADS_PATH", "priv/uploads")

config :phoenix, :json_library, Jason

config :phoenix, :format_encoders, ics: ICalendar

config :phoenix, :generators,
  migration: true,
  binary_id: false

config :scrivener_html,
  routes_helper: ChangelogWeb.Router.Helpers,
  view_style: :semantic

config :ex_aws,
  access_key_id: SecretOrEnv.get("AWS_ACCESS_KEY_ID"),
  secret_access_key: SecretOrEnv.get("AWS_SECRET_ACCESS_KEY")

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
  api_key: SecretOrEnv.get("ALGOLIA_API_KEY2")

config :mime, :types, %{"application/javascript" => ["js"], "application/xml" => ["xml"]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
