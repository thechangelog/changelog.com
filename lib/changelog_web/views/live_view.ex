defmodule ChangelogWeb.LiveView do
  use ChangelogWeb, :public_view

  alias Changelog.{Episode, Icecast}
  alias ChangelogWeb.{Endpoint, EpisodeView, PersonView, PodcastView, TimeView}

  def render("ical.ics", %{episodes: episodes}) do
    events = Enum.map(episodes, fn(episode) ->
      %ICalendar.Event{
        summary: "#{episode.podcast.name} Live",
        description: episode_title_with_subtitle(episode),
        url: Routes.live_url(Endpoint, :show, Episode.hashid(episode)),
        dtstart: episode.recorded_at,
        dtend: Timex.shift(episode.recorded_at, minutes: 90),
      }
    end)

    %ICalendar{events: events}
  end

  def episode_title_with_subtitle(episode) do
    if episode.subtitle do
      "#{episode.title} (#{episode.subtitle})"
    else
      episode.title
    end
  end

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
