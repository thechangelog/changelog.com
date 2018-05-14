defmodule ChangelogWeb.Plug.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller

  alias ChangelogWeb.Router.Helpers

  def init(opts), do: opts

  def call(conn = %{assigns: %{current_user: %{admin: true}}}, _opts), do: conn
  def call(conn, _opts) do
    conn
    |> put_flash(:error, "Admins only!")
    |> redirect(to: Helpers.root_path(conn, :index))
    |> halt()
  end
end
