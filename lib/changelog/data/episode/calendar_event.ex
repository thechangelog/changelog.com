defmodule Changelog.CalendarEvent do
  defstruct name: nil, start: nil, duration: 90,
            location: "Skype", notes: nil, attendees: []

  def build_for(episode) do
    %__MODULE__{
      name: "Recording '#{episode.podcast.name}'",
      start: episode.recorded_at,
      duration: 90,
      location: "Skype",
      notes: "Setup guide: https://changelog.com/guest/#{episode.podcast.slug}",
      attendees: attendees_from(episode)
    }
  end

  defp attendees_from(episode) do    
    Enum.map(episode.guests ++ episode.hosts, & %{email: &1.email})
  end
end
