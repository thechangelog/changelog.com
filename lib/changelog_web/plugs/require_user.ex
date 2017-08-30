defmodule ChangelogWeb.Plug.RequireUser do
  import Plug.Conn
  import Phoenix.Controller

  alias ChangelogWeb.Router.Helpers

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must sign in first.")
      |> redirect(to: Helpers.page_path(conn, :home))
      |> halt()
    end
  end
end
