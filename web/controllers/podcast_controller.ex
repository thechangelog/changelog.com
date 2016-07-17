defmodule Changelog.PodcastController do
  use Changelog.Web, :controller

  alias Changelog.Podcast
  alias Changelog.Episode

  def index(conn, _params) do
    render conn, "index.html"
  end

  def show(conn, %{"slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: slug)
    |> Podcast.preload_hosts

    episodes =
      assoc(podcast, :episodes)
      |> Episode.published
      |> Episode.newest_first
      |> Episode.limit(5)
      |> Repo.all
      |> Episode.preload_guests

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

  def master(conn, _params) do
    episodes =
      Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_all

    render conn, "master.html", podcast: stub_master_podcast, episodes: episodes
  end

  def master_feed(conn, _params) do
    episodes =
      Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_all

    conn
    |> put_layout(false)
    |> put_resp_content_type("application/xml")
    |> render("master.xml", podcast: stub_master_podcast, episodes: episodes)
  end

  defp stub_master_podcast do
    %Podcast{
      name: "Changelog Master Feed",
      description: "git pull changelog master",
      keywords: "changelog, open source, oss, software, development, developer"
    }
  end
end
