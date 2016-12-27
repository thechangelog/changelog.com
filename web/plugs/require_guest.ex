defmodule Changelog.Plug.RequireGuest do
  import Plug.Conn
  import Phoenix.Controller

  alias Changelog.Router.Helpers

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    if !conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Guests only!")
      |> redirect(to: Helpers.page_path(conn, :home))
      |> halt()
    end
  end
end
