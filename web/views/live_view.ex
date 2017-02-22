defmodule Changelog.LiveView do
  use Changelog.Web, :public_view

  alias Changelog.{EpisodeView, PersonView}

  def host_or_guest(episode, person) do
    if Enum.member?(episode.hosts, person) do
      "Host"
    else
      "Guest"
    end
  end
end
