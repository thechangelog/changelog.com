defmodule ChangelogWeb.Plug.RequireAdminPreview do
  @moduledoc """
  Restricts editorial previews to admins and prevents shared caching.
  Also used when episode playback or image requests resolve to a draft.
  """
  import Plug.Conn

  def init(opts), do: opts

  def call(conn, _opts) do
    conn =
      conn
      |> put_resp_header("cache-control", "private, no-store, must-revalidate")
      |> put_resp_header("surrogate-control", "no-store")
      |> delete_resp_header("surrogate-key")

    case conn.assigns[:current_user] do
      %{admin: true} -> conn
      _ -> conn |> send_resp(404, "Not Found") |> halt()
    end
  end
end
