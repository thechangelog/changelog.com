defmodule Changelog.Plug.RequireUser do
  import Plug.Conn
  import Phoenix.Controller

  alias Changelog.Router.Helpers

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "You must sign in first.")
      |> redirect(to: Helpers.page_path(conn, :index))
      |> halt()
    end
  end
end
