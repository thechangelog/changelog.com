defmodule Changelog.PodcastController do
  use Changelog.Web, :controller

  alias Changelog.{Podcast, Episode}

  def index(conn, _params) do
    render(conn, :index)
  end

  def show(conn, %{"slug" => slug}) do
    podcast = Podcast.get_by_slug(slug)

    episodes =
      Podcast.get_episodes(podcast)
      |> Episode.published
      |> Episode.newest_first
      |> Episode.limit(5)
      |> Repo.all
      |> Episode.preload_podcast
      |> Episode.preload_guests

    render(conn, :show, podcast: podcast, episodes: episodes)
  end

  def archive(conn, %{"slug" => slug}) do
    podcast = Podcast.get_by_slug(slug)

    episodes =
      Podcast.get_episodes(podcast)
      |> Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_podcast
      |> Episode.preload_guests

    render(conn, :archive, podcast: podcast, episodes: episodes)
  end
end
