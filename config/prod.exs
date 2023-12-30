import Config

static_url_host = System.get_env("STATIC_URL_HOST", "cdn.changelog.com")

config :changelog, ChangelogWeb.Endpoint,
  http: [port: System.get_env("HTTP_PORT", "4000")],
  url: [
    scheme: System.get_env("URL_SCHEME", "https"),
    host: System.get_env("URL_HOST", "changelog.com"),
    port: System.get_env("URL_PORT", "443")
  ],
  static_url: [
    scheme: System.get_env("STATIC_URL_SCHEME", "https"),
    host: static_url_host,
    port: System.get_env("STATIC_URL_PORT", "443"),
    path: "/static"
  ],
  cache_static_manifest: "priv/static/cache_manifest.json",
  # we don't need vsn=?d because Plug.Static doesn't serve static assets in prod
  cache_manifest_skip_vsn: true

# Serve Waffle static assets from our CDN, usually cdn.changelog.com
config :waffle,
  asset_host: "https://#{static_url_host}"

config :logger,
  level: :info,
  backends: [:console, Sentry.LoggerBackend]

config :changelog, Changelog.Repo,
  adapter: Ecto.Adapters.Postgres,
  database: System.get_env("DB_NAME", "changelog"),
  hostname: System.get_env("DB_HOST", "db"),
  username: System.get_env("DB_USER", "postgres"),
  ssl: true,

  # 💥 According to https://neon.tech/docs/guides/elixir-ecto#configure-ecto, server_name_indication should work, but it fails with:
  # ** (Postgrex.Error) ERROR 26000 (invalid_sql_statement_name) prepared statement "ecto_1922" does not exist
  # ssl_opts: [
  #   server_name_indication: String.to_charlist(System.get_env("DB_HOST", "db")),
  #   verify: :verify_none
  # ],

  # 💥 According to https://neon.tech/docs/guides/elixir-ecto#configure-ecto, this should work, but it fails with:
  # 17:41:53.361 [notice] Application changelog exited: Changelog.Application.start(:normal, []) returned an error: shutdown: failed to start child: Changelog.EpisodeTracker
  #    ** (EXIT) an exception was raised:
  #        ** (DBConnection.ConnectionError) connection not available and request was dropped from queue after 2955ms. This means requests are coming in and your connection pool cannot serve them fast enough. You can address this by:
  #
  #  1. Ensuring your database is available and that you can connect to it
  #  2. Tracking down slow queries and making sure they are running fast enough
  #  3. Increasing the pool_size (although this increases resource consumption)
  #  4. Allowing requests to wait longer by increasing :queue_target and :queue_interval
  #
  #See DBConnection.start_link/2 for more information
  #
  #            (ecto_sql 3.10.2) lib/ecto/adapters/sql.ex:1047: Ecto.Adapters.SQL.raise_sql_call_error/1
  #            (ecto_sql 3.10.2) lib/ecto/adapters/sql.ex:945: Ecto.Adapters.SQL.execute/6
  #            (ecto 3.10.3) lib/ecto/repo/queryable.ex:229: Ecto.Repo.Queryable.execute/4
  #            (ecto 3.10.3) lib/ecto/repo/queryable.ex:19: Ecto.Repo.Queryable.all/3
  #            (changelog 0.0.1) lib/changelog/schema/episode/episode.ex:421: Changelog.Episode.flatten_for_filtering/1
  #            (changelog 0.0.1) lib/changelog/episode_tracker.ex:130: Changelog.EpisodeTracker.refresh_episodes/0
  #            (changelog 0.0.1) lib/changelog/episode_tracker.ex:57: Changelog.EpisodeTracker.init/1
  #            (stdlib 5.2) gen_server.erl:980: :gen_server.init_it/2
  # ssl_opts: [
  #   cacerts: :public_key.cacerts_get(), # available since OTP26
  #   verify: :verify_peer,
  #   server_name_indication: String.to_charlist(System.get_env("DB_HOST", "db")),
  #   customize_hostname_check: [
  #     match_fun: :public_key.pkix_verify_hostname_match_fun(:https)
  #   ]
  # ],

  # 🤔 This combined with prepending endpoint=<endpoint_id> is the only thing that works 🤔
  ssl_opts: [ verify: :verify_none ],
  password: SecretOrEnv.get("DB_PASS"),
  timeout: 60000,
  pool_size: 40

config :changelog, Changelog.Mailer,
  adapter: Bamboo.SMTPAdapter,
  server: "smtp.api.createsend.com",
  port: 587,
  username: SecretOrEnv.get("CM_SMTP_TOKEN"),
  password: SecretOrEnv.get("CM_SMTP_TOKEN")

config :elixir,
  :time_zone_database, Tzdata.TimeZoneDatabase

config :changelog, Oban,
  plugins: [
    {Oban.Plugins.Pruner, max_age: 43_200}, # 12 hours
    {Oban.Plugins.Cron,
     timezone: "US/Central",
     crontab: [
       {"00 3 * * *", Changelog.ObanWorkers.SlackImporter},
       {"30 3 * * *", Changelog.ObanWorkers.Bouncer},
       {"00 4 * * *", Changelog.ObanWorkers.StatsProcessor},
       {"* * * * *", Changelog.ObanWorkers.NewsPublisher}
     ]}
  ]
