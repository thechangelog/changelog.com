use Mix.Config

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with brunch.io to recompile .js and .css sources.
config :changelog, ChangelogWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [yarn: ["start", cd: Path.expand("../assets", __DIR__)]]

# Watch static and templates for browser reloading.
# config :changelog, ChangelogWeb.Endpoint,
#   live_reload: [
#     patterns: [
#       ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
#       ~r{lib/changelog/web/views/.*(ex)$},
#       ~r{lib/changelog/web/templates/.*(eex)$}
#     ]
#   ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

# Configure CalendarService
config :changelog, Changelog.CalendarService,
  adapter: Changelog.CalendarService

# Configure your database
config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: "changelog_dev",
  pool_size: 10

config :arc,
  storage_dir: "priv/uploads"

config :rollbax,
  access_token: "",
  environment: "development",
  enabled: :log
