defmodule ChangelogWeb.Plug.HealthCheck do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn = %Plug.Conn{request_path: "/health"}, _opts) do
    conn
    |> send_resp(200, "")
    |> halt()
  end

  def call(conn, _opts), do: conn
end
