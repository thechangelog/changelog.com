defmodule Changelog.Files.Audio do
  use Changelog.File, [:mp3]

  alias ChangelogWeb.{PodcastView}

  @versions [:original]

  def storage_dir(_, {_, scope}), do: expanded_dir("/#{scope.podcast.slug}/#{scope.slug}")
  def filename(_, {_, scope}), do: "#{PodcastView.dasherized_name(scope.podcast)}-#{scope.slug}"

  def transform(_version, {_file, scope}) do
    podcast = scope.podcast

    # get podcast's cover art location and insert list of art options
    art_file = PodcastView.cover_art_local_path(podcast, "png")

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
