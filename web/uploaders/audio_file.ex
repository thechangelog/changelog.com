defmodule Changelog.AudioFile do
  use Arc.Definition
  use Arc.Ecto.Definition

  @versions [:original]

  def __storage, do: Arc.Storage.Local

  def validate({file, _}) do
    ~w(.mp3) |> Enum.member?(Path.extname(file.file_name))
  end

  def filename(_version, {_file, scope}) do
    "#{Changelog.PodcastView.dasherized_name(scope.podcast)}-#{scope.slug}"
  end

  def storage_dir(_version, {_file, scope}) do
    Application.app_dir(:changelog, "priv/uploads/#{scope.podcast.slug}/#{scope.slug}")
  end

  def transform(_version, {_file, scope}) do
    podcast = scope.podcast

    # get podcast's cover art location and insert list of art options
    art_file = Changelog.PodcastView.cover_art_local_path(podcast, "png")

    {:ffmpeg,
     fn(input, output) ->
      [
        "-f", "mp3",
        "-i", input,
        "-i", art_file, "-map", "0:0", "-map", "1:0",
        "-acodec", "copy",
        "-metadata", "artist=Changelog Media",
        "-metadata", "publisher=Changelog Media",
        "-metadata", "album=#{podcast.name}",
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
