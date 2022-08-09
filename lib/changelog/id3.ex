defmodule Changelog.Id3 do
  alias Changelog.StringKit
  alias Id3vx.Tag

  @text_frames %{
    "artist"    => "TPE1",
    "title"     => "TIT2",
    "subtitle"  => "TIT3",
    "album"     => "TALB",
    "year"      => "TYER",
    "genre"     => "TCON",
    "publisher" => "TPUB"
  }

  def tag_for_episode(episode) do
    Tag.create(3)
    |> add_text("artist", "Changelog Media")
    |> add_text("publisher", "Changelog Media")
    |> add_text("genre", "Podcast")
    |> add_text("album", episode.podcast.name)
    |> add_text("title", episode.title)
    |> add_text("subtitle", episode.subtitle)
  end

  def add_chapters(tag, []), do: tag
  def add_chapters(tag, chapters) do
    Enum.reduce(chapters, tag, fn(c, acc) ->
      Tag.add_typical_chapter_and_toc(acc,
        in_milliseconds(c.starts_at),
        in_milliseconds(c.ends_at),
        0, 0, # settings start/end offsets to zero forces use of start/end times
        c.title, fn(chapter) ->
          if StringKit.present?(c.link_url) do
            Tag.add_custom_url(chapter, "chapter link", c.link_url)
          else
            chapter
          end
        end)
    end)
  end

  def add_image(tag, image_path, mime_type) do
    Tag.add_attached_picture(tag, "", mime_type, File.read!(image_path))
  end

  def add_text(tag, _type, ""), do: tag
  def add_text(tag, _type, nil), do: tag
  def add_text(tag, type, text) do
    Tag.add_text_frame(tag, @text_frames[type], text)
  end

  defp in_milliseconds(seconds) do
    round(seconds * 1000)
  end
end
