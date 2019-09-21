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

  def status_class(episode) do
    if should_be_complete(episode), do: "is-complete", else: "is-upcoming"
  end

  def should_be_complete(episode) do
    Timex.after?(TimeView.hours_ago(2), episode.recorded_at)
  end

  def should_be_live(episode) do
     Timex.between?(episode.recorded_at, TimeView.hours_ago(2), Timex.now())
  end

  def slack_channel(podcast) do
    case podcast.slug do
      "spotlight" -> "applenerds"
      slug -> slug
    end
  end
end
