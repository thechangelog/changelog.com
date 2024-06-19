defmodule ChangelogWeb.Endpoint do
  use Sentry.PlugCapture
  use Phoenix.Endpoint, otp_app: :changelog

  cookie_domain =
    if Mix.env() == :prod do
      ".changelog.com"
    else
      System.get_env("HOST", "localhost")
    end

  @session_options [
    store: :cookie,
    key: "_changelog_key",
    encryption_salt: System.get_env("ENCRYPTION_SALT") || "8675309",
    max_age: 31_536_000,
    signing_salt: System.get_env("SIGNING_SALT") || "8bAOekZm",
    extra: "SameSite=Lax",
    domain: cookie_domain
  ]

  socket "/live", Phoenix.LiveView.Socket, websocket: [connect_info: [session: @session_options]]
  socket "/socket", ChangelogWeb.UserSocket,
    # or list of options
    websocket: true

  plug ChangelogWeb.Plug.HealthCheck

  # Legacy assets that will exist in production & may exist in dev
  plug Plug.Static,
    at: "/wp-content",
    from: {:changelog, "priv/wp-content"},
    gzip: false,
    headers: %{
      "cache-control" => "max-age=#{3600 * 24 * 366}, public",
      "surrogate-control" =>
        Application.compile_env(:changelog, :cdn_cache_control_s3)
    }

  # In production static assets are served by the CDN
  if Mix.env() != :prod do
    plug Plug.Static,
      at: "/static",
      from: :changelog,
      gzip: true,
      only_matching: ~w(css fonts images js android-chrome apple-touch
        browserconfig favicon manifest mstile robots safari-pinned-tab)
  end

  # App should always serve build identifiers,
  # like git sha (a.k.a. version) via /static/version.txt
  # and build url via /static/build.txt
  plug Plug.Static,
    at: "/static",
    from: :changelog,
    gzip: true,
    only_matching: ~w(version build)

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
    plug Phoenix.Ecto.CheckRepoStatus, otp_app: :changelog
  end

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  # This must come before Plug.Parsers so raw body hasn't been dropped yet
  plug ChangelogWeb.Plug.StripeWebhooks

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library(),
    length: 512_000_000

  # This must come after Plug.Parsers according to Sentry's docs
  plug Sentry.PlugContext

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug ChangelogWeb.Router
end
