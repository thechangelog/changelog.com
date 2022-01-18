defmodule ChangelogWeb.Endpoint do
  use Sentry.PlugCapture
  use Phoenix.Endpoint, otp_app: :changelog

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
        Application.get_env(:changelog, ChangelogWeb.Endpoint)[:cdn_static_cache]
    }

  # In production static assets are served by the CDN
  if Mix.env() != :prod do
    plug Plug.Static,
      at: "/static",
      from: :changelog,
      gzip: true,
      only_matching: ~w(css fonts images js android-chrome apple-touch
        browserconfig favicon manifest mstile robots safari-pinned-tab version build)
  end

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    socket "/phoenix/live_reload/socket", Phoenix.LiveReloader.Socket
    plug Phoenix.LiveReloader
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId

  if Changelog.PromEx.bearer_token() == "" do
    plug PromEx.Plug, prom_ex_module: Changelog.PromEx
  else
    plug Unplug,
      if: ChangelogWeb.Plugs.MetricsPredicate,
      do: {PromEx.Plug, prom_ex_module: Changelog.PromEx}
  end

  plug Unplug,
    if: {Unplug.Predicates.RequestPathNotIn, ["/metrics"]},
    do: {Plug.Telemetry, event_prefix: [:phoenix, :endpoint]}

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library(),
    length: 256_000_000

  plug Sentry.PlugContext
  plug Plug.MethodOverride
  plug Plug.Head

  cookie_domain =
    if Mix.env() == :prod do
      ".changelog.com"
    else
      System.get_env("HOST", "localhost")
    end

  plug Plug.Session,
    store: :cookie,
    key: "_changelog_key",
    encryption_salt: System.get_env("ENCRYPTION_SALT") || "8675309",
    max_age: 31_536_000,
    signing_salt: System.get_env("SIGNING_SALT") || "8bAOekZm",
    extra: "SameSite=Lax",
    domain: cookie_domain

  plug ChangelogWeb.Router
end
