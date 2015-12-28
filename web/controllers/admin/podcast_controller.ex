defmodule Changelog.Admin.PodcastController do
  use Changelog.Web, :controller

  alias Changelog.Podcast

  plug :scrub_params, "podcast" when action in [:create, :update]

  def index(conn, _params) do
    podcasts = Repo.all from p in Podcast, order_by: p.id
    render conn, "index.html", podcasts: podcasts
  end
end
