defmodule Changelog.PodcastView do
  use Changelog.Web, :view

  def numbered_episode_title(episode) do
    case Float.parse(episode.slug) do
      {_, _} -> "#{episode.slug}: #{episode.title}"
      :error -> episode.title
    end
  end
end
