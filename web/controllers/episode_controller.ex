defmodule Changelog.EpisodeController do
  use Changelog.Web, :controller

  alias Changelog.{Podcast, Episode}

  def show(conn, %{"podcast" => podcast, "slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: podcast)

    episode =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Repo.get_by!(slug: slug)
      |> Repo.preload(:podcast)
      |> Episode.preload_guests
      |> Episode.preload_sponsors

    render conn, :show, podcast: podcast, episode: episode
  end
end
