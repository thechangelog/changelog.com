import Config

port = 4000
config :changelog, ChangelogWeb.Endpoint,
  http: [port: port, ip: {0, 0, 0, 0, 0, 0, 0, 0}],
  url: [host: System.get_env("HOST", "localhost")],
  check_origin: false,
  static_url: [host: System.get_env("HOST", "localhost"), path: "/static"],
  debug_errors: true,
  code_reloader: true,
  cache_static_lookup: false,
  check_origin: false,
  watchers: [
    yarn: ["start", cd: Path.expand("../assets", __DIR__)]
  ]

# Update the static_url config if running inside a GitHub Codespaces VS Code web editor to allow assets
# to load when viewing the forwarded port's URL.
# "CODESPACES_WEB" is manually set by devs, the other env vars are set by Codespaces automatically
# https://docs.github.com/en/codespaces/developing-in-codespaces/default-environment-variables-for-your-codespace
if System.get_env("CODESPACES_WEB") do
  codespaces_host = "#{System.get_env("CODESPACE_NAME")}-#{port}.#{System.get_env("GITHUB_CODESPACES_PORT_FORWARDING_DOMAIN")}"

  config :changelog, ChangelogWeb.Endpoint,
    static_url: [host: codespaces_host, path: "/static", port: 80]
end

# Live reloading is opt-in
if System.get_env("LIVE_RELOAD") do
  config :changelog, ChangelogWeb.Endpoint,
    live_reload: [
      patterns: [
        ~r{priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$},
        ~r{lib/changelog_web/(live|views)/.*(ex)$},
        ~r{lib/changelog_web/templates/.*(eex)$}
      ]
    ]
end

# Sometimes we need HTTPS, like when futzing with captchas
if System.get_env("HTTPS") do
  config :changelog, ChangelogWeb.Endpoint,
    https: [
      port: 4001,
      cipher_suite: :strong,
      certfile: "priv/cert/selfsigned.pem",
      keyfile: "priv/cert/selfsigned_key.pem"
    ]
end

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development.
# Do not configure such in production as keeping
# and calculating stacktraces is usually expensive.
config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

# Serve Waffle static assets from Cloudflare R2 changelog-assets-dev, the r2.dev subdomain
config :waffle,
  asset_host: System.get_env("CDN_PUBLIC_HOST", "https://pub-09bcfd436e22494a8f79ac4e8cd51197.r2.dev")

config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME", "changelog_dev"),
  hostname: System.get_env("DB_HOST", "localhost"),
  username: System.get_env("DB_USER", "postgres"),
  password: System.get_env("DB_PASS", "postgres"),
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

if String.contains?(System.get_env("DB_HOST", "localhost"), "neon.tech") do
  config :changelog, Changelog.Repo,
      ssl: true,
      ssl_opts: [
        # The cacertfile value implies macOS - tested on macOS 12.7.3 by @gerhard - March 28, 2024
        cacertfile: "/etc/ssl/cert.pem",
        # The followin also works on macOS ARM + brew install openssl@3
        # cacertfile: "/opt/homebrew/etc/openssl@3/cert.pem",
        verify: :verify_peer,
        server_name_indication: String.to_charlist(System.get_env("DB_HOST", "db")),
        customize_hostname_check: [
          match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
        ]
      ]
end
