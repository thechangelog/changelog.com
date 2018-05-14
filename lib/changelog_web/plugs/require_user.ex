defmodule ChangelogWeb.Plug.RequireUser do
  import Plug.Conn
  import Phoenix.Controller

  alias ChangelogWeb.Router.Helpers

  def init(opts), do: opts

  def call(conn, _opts) do
    if conn.assigns[:current_user] do
      conn
    else
      conn
      |> put_flash(:error, "Please sign in first. ✊")
      |> redirect(to: Helpers.sign_in_path(conn, :new))
      |> halt()
    end
  end
end
