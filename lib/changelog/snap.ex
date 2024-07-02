defmodule Changelog.Snap do
  use ChangelogWeb, :verified_routes

  require Logger

  alias Changelog.{HTTP, Episode, Podcast}

  @base_url "https://snap.fly.dev"

  @doc """
  Pass in an episode to `purge` its Snap image
  """
  def purge(episode = %Episode{}) do
    auth = Application.get_env(:changelog, :snap_token)
    HTTP.request(:delete, img_url(episode), "", [{"x-snap-token", auth}])
  end

  def img_url(episode = %Episode{}) do
    episode = Episode.preload_podcast(episode)

    img_url(episode.podcast, episode)
  end

  def img_url(podcast = %Podcast{}, episode = %Episode{}) do
    @base_url <> ~p"/#{podcast.slug}/#{episode.slug}/img"
  end
end
