defmodule Changelog.PodcastController do
  use Changelog.Web, :controller

  alias Changelog.Podcast

  def show(conn, %{"slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: slug)
      |> Repo.preload([podcast_hosts: {Changelog.PodcastHost.by_position, :person}])
    render conn, "show.html", podcast: podcast
  end

  def episode(conn, %{"podcast" => podcast, "slug" => slug}) do
    podcast = Repo.get_by!(Podcast, slug: podcast)

    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug, published: true)
      |> Repo.preload([
        episode_hosts: {Changelog.EpisodeHost.by_position, :person},
        episode_guests: {Changelog.EpisodeGuest.by_position, :person},
        episode_topics: {Changelog.EpisodeTopic.by_position, :topic}
      ])

    render conn, "episode.html", podcast: podcast, episode: episode
  end
end
