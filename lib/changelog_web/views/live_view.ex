defmodule ChangelogWeb.LiveView do
  use ChangelogWeb, :public_view

  alias Changelog.Wavestreamer
  alias ChangelogWeb.{EpisodeView, PersonView, PodcastView}

  def host_or_guest(episode, person) do
    if Enum.member?(episode.hosts, person) do
      "Host"
    else
      "Guest"
    end
  end

  def slack_channel(podcast) do
    case podcast.slug do
      "spotlight" -> "applenerds"
      slug -> slug
    end
  end
end
