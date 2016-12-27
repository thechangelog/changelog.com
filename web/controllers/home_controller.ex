defmodule Changelog.HomeController do
  use Changelog.Web, :controller

  plug RequireUser

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
