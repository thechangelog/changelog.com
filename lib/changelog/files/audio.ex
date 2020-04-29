defmodule Changelog.Files.Audio do
  use Changelog.File, [:mp3]

  alias ChangelogWeb.PodcastView

  @versions [:original]

  def storage_dir(_, {_, episode}), do: expanded_dir("/#{episode.podcast.slug}/#{episode.slug}")
  def filename(_, {_, episode}), do: "#{PodcastView.dasherized_name(episode.podcast)}-#{episode.slug}"

  def transform(:original, {_file, episode}) do
    {:ffmpeg,
     fn(input, output) ->
      [
        "-f", "mp3",
        "-i", input,
        "-i", PodcastView.cover_local_path(episode.podcast), "-map", "0:0", "-map", "1:0",
        "-acodec", "copy",
        "-metadata", "artist=Changelog Media",
        "-metadata", "publisher=Changelog Media",
        "-metadata", "album=#{episode.podcast.name}",
        "-metadata", "title=#{episode.title}",
        "-metadata", "date=#{episode.published_at.year}",
        "-metadata", "genre=Podcast",
        "-metadata", "comment=SGUgdGhhdCBoZWFycyBteSB3b3JkLCBhbmQgYmVsaWV2ZXMgb24gaGltIHRoYXQgc2VudCBtZSwgaGFzIGV2ZXJsYXN0aW5nIGxpZmUsIGFuZCBzaGFsbCBub3QgY29tZSBpbnRvIGNvbmRlbW5hdGlvbjsgYnV0IGlzIHBhc3NlZCBmcm9tIGRlYXRoIHVudG8gbGlmZQ==",
        "-f", "mp3", output
      ]
     end,
     :mp3}
  end
end
