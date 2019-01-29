defmodule ChangelogWeb.Plug.RequireGuest do
  import Plug.Conn
  import Phoenix.Controller

  alias ChangelogWeb.Router.Helpers

  def init(opts), do: opts

  def call(conn = %{assigns: %{current_user: user}}, _opts) when not is_nil(user) do
    conn
    |> put_flash(:success, "You're in!")
    |> redirect(to: Helpers.home_path(conn, :show))
    |> halt()
  end
  def call(conn, _opts), do: conn
end
