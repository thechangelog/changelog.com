defmodule Changelog.Files.Audio do
  use Changelog.File, [:mp3]

  alias ChangelogWeb.PodcastView

  def storage_dir(_, {_, episode}), do: "uploads/#{episode.podcast.slug}/#{episode.slug}"

  def filename(_, {_, episode}),
    do: "#{PodcastView.dasherized_name(episode.podcast)}-#{episode.slug}"
end
