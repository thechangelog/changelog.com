defmodule Changelog.AudioFile do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original]

  def validate({file, _}) do
    ~w(.mp3) |> Enum.member?(Path.extname(file.file_name))
  end

  def filename(_version, {file, scope}) do
    "#{Changelog.PodcastView.dasherized_name(scope.podcast)}-#{scope.slug}"
  end

  def __storage, do: Arc.Storage.Local

  def storage_dir(_version, {file, scope}) do
    "uploads/audio/#{scope.podcast.slug}/#{scope.slug}"
  end

  def transform(_version, {file, scope}) do
    {:ffmpeg,
     fn(input, output) ->
      [
        "-f", "mp3", # input file is an mp3
        "-i", input,
        "-acodec", "copy", # don't re-encode
        "-metadata", "artist=Changelog Media",
        "-metadata", "publisher=Changelog Media",
        "-metadata", "album=#{scope.podcast.name}",
        "-metadata", "title=#{scope.title}",
        "-metadata", "date=#{scope.published_at.year}",
        "-metadata", "genre=Podcast",
        "-metadata", "comment=SGUgdGhhdCBoZWFycyBteSB3b3JkLCBhbmQgYmVsaWV2ZXMgb24gaGltIHRoYXQgc2VudCBtZSwgaGFzIGV2ZXJsYXN0aW5nIGxpZmUsIGFuZCBzaGFsbCBub3QgY29tZSBpbnRvIGNvbmRlbW5hdGlvbjsgYnV0IGlzIHBhc3NlZCBmcm9tIGRlYXRoIHVudG8gbGlmZQ==",
        "-f", "mp3", output
      ]
     end,
     :mp3}
  end
end
