use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :changelog, Changelog.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [npm: ["start", cd: Path.expand("../", __DIR__)]]

# Watch static and templates for browser reloading.
config :changelog, Changelog.Endpoint,
  live_reload: [
    patterns: [
      ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
      ~r{web/views/.*(ex)$},
      ~r{web/templates/.*(eex)$}
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure your database
config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  url: ( # when the DB_URL is missing: use the default value
    System.get_env("DB_URL") || "postgres://postgres@localhost:5432/changelog"
  ) <> "_dev",
  pool_size: 10

config :arc,
  storage_dir: "priv/uploads"
