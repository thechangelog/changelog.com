defmodule ChangelogWeb.Plug.RequireAdmin do
  import Plug.Conn
  import Phoenix.Controller

  alias ChangelogWeb.Router.Helpers

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    user = conn.assigns[:current_user]

    if user && user.admin do
      conn
    else
      conn
      |> put_flash(:error, "Admins only!")
      |> redirect(to: Helpers.root_path(conn, :index))
      |> halt()
    end
  end
end
