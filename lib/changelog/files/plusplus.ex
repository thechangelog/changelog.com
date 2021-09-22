defmodule Changelog.Files.PlusPlus do
  use Changelog.File, [:mp3]

  alias Changelog.Files.Audio

  @versions [:original]

  def storage_dir(version, {file, scope}), do: Audio.storage_dir(version, {file, scope})

  def filename(_, {_, episode}) do
    [
      ChangelogWeb.PodcastView.dasherized_name(episode.podcast),
      episode.slug,
      Changelog.Episode.hashid(episode)
    ]
    |> Enum.join("-")
  end
end
