defmodule ChangelogWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :changelog

  socket "/socket", ChangelogWeb.UserSocket,
    websocket: true # or list of options

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phoenix.digest
  # when deploying your static files in production.
  plug Plug.Static,
    at: "/", from: :changelog, gzip: true,
    only: ~w(css fonts images js favicon.ico robots.txt)

  # In dev environment, serve uploaded files from "priv/uploads".
  #
  # Nginx will serve these in production.
  if Mix.env == :dev do
    plug Plug.Static,
      at: "/uploads", from: {:changelog, "priv/uploads"}, gzip: false, headers: %{"Accept-Ranges" => "bytes"}
  end

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Plug.RequestId
  plug Plug.Logger

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison,
    length: 200_000_000

  plug Plug.MethodOverride
  plug Plug.Head

  plug Plug.Session,
    store: :cookie,
    key: "_changelog_key",
    signing_salt: System.get_env("SIGNING_SALT") || "8bAOekZm"

  plug ChangelogWeb.Router
end
