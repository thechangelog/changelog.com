defmodule ChangelogWeb.Plug.Authenticate do
  import Plug.Conn
  import ChangelogWeb.Plug.Conn

  def init(opts), do: Keyword.fetch!(opts, :repo)

  def call(conn, repo) do
    user_id = get_encrypted_cookie(conn, "_changelog_user")

    cond do
      user = conn.assigns[:current_user] -> assign(conn, :current_user, user)
      user = user_id && repo.get(Changelog.Person, user_id) -> assign(conn, :current_user, user)
      true -> assign(conn, :current_user, nil)
    end
  end
end
