defmodule Changelog.FFmpeg do
  @doc """
  Extracts fmpeg's report of the given `file`'s duration. e.g - "56:18"
  """
  def duration(file) do
    try do
      {info, _exit_code} = System.cmd("ffmpeg", ["-i", file], stderr_to_stdout: true)
      [_match, duration] = Regex.run(~r/Duration: (.*?),/, info)
      duration
    catch
      _all ->
        "0"
    end
  end

  @doc """
  Writes ID3 tags to the given `file` path for the given `episode`
  """
  def tag(file, episode) do
    cover_path = ChangelogWeb.PodcastView.cover_path(episode.podcast, :original)
    cover_file = Changelog.UrlKit.get_tempfile(cover_path)
    tagged = file <> "-TAGGED"

    args = [
      "-f", "mp3", "-i", file, "-i", cover_file,
      "-map", "0:0", "-map", "1:0",
      "-acodec", "copy",
      "-metadata", "artist=Changelog Media",
      "-metadata", "publisher=Changelog Media",
      "-metadata", "album=#{episode.podcast.name}",
      "-metadata", "title=#{episode.title}",
      "-metadata", "date=#{episode.published_at.year}",
      "-metadata", "genre=Podcast",
      "-metadata", "comment=SGUgdGhhdCBoZWFycyBteSB3b3JkLCBhbmQgYmVsaWV2ZXMgb24gaGltIHRoYXQgc2VudCBtZSwgaGFzIGV2ZXJsYXN0aW5nIGxpZmUsIGFuZCBzaGFsbCBub3QgY29tZSBpbnRvIGNvbmRlbW5hdGlvbjsgYnV0IGlzIHBhc3NlZCBmcm9tIGRlYXRoIHVudG8gbGlmZQ==",
      "-f", "mp3", tagged
    ]

    case System.cmd("ffmpeg", args, stderr_to_stdout: true) do
      {_info, 0} ->
        File.rename(tagged, file)
      {error_message, _exit_code} ->
        {:error, error_message}
    end
  end
end
