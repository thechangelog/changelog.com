defmodule Changelog.PodcastController do
  use Changelog.Web, :controller

  alias Changelog.Podcast
  alias Changelog.Episode

  def show(conn, %{"slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: slug)
      |> Repo.preload([podcast_hosts: {Changelog.PodcastHost.by_position, :person}])

    episodes =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Episode.newest_first
      |> Repo.all

    render conn, "show.html", podcast: podcast, episodes: episodes
  end

  def episode(conn, %{"podcast" => podcast, "slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: podcast)

    episode =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Repo.get_by!(slug: slug)
      |> Repo.preload([
        episode_hosts: {Changelog.EpisodeHost.by_position, :person},
        episode_guests: {Changelog.EpisodeGuest.by_position, :person},
        episode_channels: {Changelog.EpisodeChannel.by_position, :channel}
      ])

    render conn, "episode.html", podcast: podcast, episode: episode
  end

  def feed(conn, %{"slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: slug)

    episodes =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_all

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("feed.xml", podcast: podcast, episodes: episodes)
  end
end
