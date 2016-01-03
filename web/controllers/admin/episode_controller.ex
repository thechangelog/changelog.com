defmodule Changelog.Admin.EpisodeController do
  use Changelog.Web, :controller

  alias Changelog.Podcast
  alias Changelog.Episode

  def index(conn, %{"podcast_id" => podcast_id}) do
    podcast = Repo.get!(Podcast, podcast_id)
    episodes = Repo.all from e in Episode, where: e.podcast_id == ^podcast.id
    render conn, "index.html", podcast: podcast, episodes: episodes
  end
end
