use Mix.Config

config :changelog, Changelog.Endpoint,
  http: [port: {:system, "PORT"}],
  url: [scheme: "https", host: "2016.changelog.com", port: 443],
  static_url: [scheme: "https", host: "2016.changelog.com", port: 443],
  # remove once app is stable and ready to go live
  debug_errors: true

# Temporary log debug, replace with commented logger once app is stable and ready to go live
# config :logger, level: :info
config :logger, :console, format: "[$level] $message\n"

# Temporary production debug, remove once app is stable and ready to go live
config :phoenix, :stacktrace_depth, 10

config :changelog, Changelog.Repo,
  url: {:system, "DB_URL"},
  adapter: Ecto.Adapters.Postgres,
  pool_size: 20
