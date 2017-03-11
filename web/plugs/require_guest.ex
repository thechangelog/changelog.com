defmodule Changelog.Plug.RequireGuest do
  import Plug.Conn
  import Phoenix.Controller

  alias Changelog.Router.Helpers

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
      |> put_flash(:success, "You're in!")
      |> redirect(to: Helpers.home_path(conn, :show))
      |> halt()
    else
      conn
    end
  end
end
