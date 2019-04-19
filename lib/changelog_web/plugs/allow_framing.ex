defmodule ChangelogWeb.Plug.AllowFraming do
  import Plug.Conn

  def init(opts), do: opts

  def call(conn = %{request_path: path}, _opts) do
    if String.ends_with?(path, "embed") do
      delete_resp_header(conn, "x-frame-options")
    else
      conn
    end
  end
end
