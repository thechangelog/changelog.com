defmodule Changelog.Admin.EpisodeController do
  use Changelog.Web, :controller

  alias Changelog.Podcast
  # alias Changelog.Episode

  def index(conn, %{"podcast_id" => podcast_id}) do
    podcast = Repo.get!(Podcast, podcast_id)
    render conn, "index.html", podcast: podcast, episodes: []
  end
end
