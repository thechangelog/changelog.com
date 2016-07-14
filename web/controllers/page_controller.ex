defmodule Changelog.PageController do
  use Changelog.Web, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def weekly(conn, _params) do
    render(conn, :weekly)
  end
end
