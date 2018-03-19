defmodule Changelog.CalendarEventTest do
  use Changelog.DataCase

  alias Changelog.Episode
  alias Changelog.CalendarEvent

  test "build a calendar event from an Episode" do
    recorded_at = Timex.to_datetime({{2018, 4, 1}, {11, 00, 00}}, "UTC")
    episode = insert(:episode, recorded_at: recorded_at)
      |> with_episode_host
      |> with_episode_guest
      |> Episode.preload_all

    calendar_event = CalendarEvent.build_for(episode)

    assert calendar_event.name =~ episode.podcast.name
    assert calendar_event.notes =~ episode.podcast.slug
    assert calendar_event.start == episode.recorded_at
    assert contains?(calendar_event.attendees, attendees_from(episode))
  end

  defp contains?(attendes, attendes_from_episode) do
    Enum.each(attendes, & assert Enum.member?(attendes_from_episode, &1))
  end

  defp attendees_from(episode) do
    Enum.map(episode.hosts ++ episode.guests, & %{email: &1.email})
  end

  defp with_episode_host(episode) do
    insert(:episode_host, episode: episode)
    episode
  end

  defp with_episode_guest(episode) do
    insert(:episode_guest, episode: episode)
    episode
  end
end
