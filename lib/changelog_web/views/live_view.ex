defmodule ChangelogWeb.LiveView do
  use ChangelogWeb, :public_view

  alias Changelog.UrlKit
  alias ChangelogWeb.{EpisodeView, PersonView, PodcastView, TimeView}

  def render("ical.ics", %{episodes: episodes}) do
    events =
      Enum.map(episodes, fn episode ->
        %ICalendar.Event{
          summary: "#{episode.podcast.name} Live",
          description: episode_title_with_subtitle(episode),
          url: live_url(episode),
          dtstart: episode.recorded_at,
          dtend: Timex.shift(episode.recorded_at, minutes: 90)
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

  def header_for_episode_list(episodes) do
    if Enum.any?(episodes) do
      "Upcoming live shows"
    else
      "There are no upcoming live shows scheduled right now"
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

  # For use in link(to: ) calls vs just the raw url (below)
  def live_link(episode) do
    case live_url(episode) do
      nil -> {:javascript, ~s{alert("This live event is not yet configured.");}}
      url -> url
    end
  end

  def live_url(episode = %{youtube_id: id}) when not is_nil(id), do: youtube_url(episode)
  def live_url(%{podcast: %{riverside_url: url}}) when not is_nil(url), do: UrlKit.sans_query(url)
  def live_url(_else), do: nil

  defp youtube_url(%{youtube_id: id}) when is_binary(id), do: "https://youtu.be/#{id}"
  defp youtube_url(_), do: "https://youtube.com/changelog"
end
