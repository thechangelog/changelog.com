defmodule Changelog.Admin.PageController do
  use Changelog.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
