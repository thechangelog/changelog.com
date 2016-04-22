defmodule Changelog.AudioFile do
  use Arc.Definition

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  @versions [:original]

  def validate({file, _}) do
    ~w(.mp3) |> Enum.member?(Path.extname(file.file_name))
  end

  def filename(version, {file, scope}) do
    "#{Changelog.PodcastView.dasherized_name(scope.podcast)}-#{scope.slug}"
  end

  def __storage, do: Arc.Storage.Local

  def storage_dir(version, {file, scope}) do
    "audio/#{scope.podcast.slug}/#{scope.slug}"
  end
end
