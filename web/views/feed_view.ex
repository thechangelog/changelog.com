defmodule Changelog.FeedView do
  use Changelog.Web, :view

  alias Changelog.{EpisodeView, PersonView, PodcastView, PostView, TimeView}
  alias Changelog.Podcast

  def podcast_title(podcast, episode) do
    title = EpisodeView.numbered_title(episode)

    if Podcast.is_master(podcast) do
      "#{episode.podcast.name} - #{title}"
    else
      title
    end
  end
end
