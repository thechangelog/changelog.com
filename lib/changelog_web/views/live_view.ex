defmodule ChangelogWeb.LiveView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, Icecast}
  alias ChangelogWeb.{EpisodeView, PersonView, PodcastView, TimeView}

  def host_or_guest(episode, person) do
    if Enum.member?(episode.hosts, person) do
      "Host"
    else
      "Guest"
    end
  end

  def should_be_live(episode) do
    episode.recorded_at |> Timex.between?(TimeView.hours_ago(2), Timex.now())
  end

  def slack_channel(podcast) do
    case podcast.slug do
      "spotlight" -> "applenerds"
      slug -> slug
    end
  end
end
