defmodule ChangelogWeb.LiveView do
  use ChangelogWeb, :public_view

  alias Changelog.Wavestreamer
  alias ChangelogWeb.{EpisodeView, PersonView}

  def host_or_guest(episode, person) do
    if Enum.member?(episode.hosts, person) do
      "Host"
    else
      "Guest"
    end
  end
end
