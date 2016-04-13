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
        episode_topics: {Changelog.EpisodeTopic.by_position, :topic}
      ])

    render conn, "episode.html", podcast: podcast, episode: episode
  end
end
