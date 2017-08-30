defmodule ChangelogWeb.FeedView do
  use ChangelogWeb, :public_view

  alias Changelog.{Podcast}
  alias ChangelogWeb.{EpisodeView, PersonView, PodcastView, PostView, TimeView}

  def podcast_title(podcast, episode) do
    title = EpisodeView.numbered_title(episode)

    if Podcast.is_master(podcast) do
      "#{episode.podcast.name} - #{title}"
    else
      title
    end
  end
end
