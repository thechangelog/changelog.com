defmodule ChangelogWeb.Plug.RequireUser do
  import Plug.Conn
  import Phoenix.Controller

  alias ChangelogWeb.Router.Helpers

  def init(opts), do: opts

  def call(conn = %{assigns: %{current_user: user}}, _opts) when not is_nil(user), do: conn
  def call(conn, _opts) do
    conn
    |> put_flash(:error, "Please sign in first. ✊")
    |> redirect(to: Helpers.sign_in_path(conn, :new))
    |> halt()
  end
end
