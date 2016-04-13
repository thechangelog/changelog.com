defmodule Changelog.PageController do
  use Changelog.Web, :controller

  alias Changelog.Podcast

  def index(conn, _params) do
    podcasts = Repo.all(Podcast)
    render conn, "index.html", podcasts: podcasts
  end
end
