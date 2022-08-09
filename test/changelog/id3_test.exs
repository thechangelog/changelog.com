defmodule Changelog.Id3Test do
  use Changelog.SchemaCase

  alias Changelog.Id3

  def find_text_frame(tag, text) do
    Enum.find(tag.frames, fn(f) -> Enum.member?(f.data.text, text) end)
  end

  def find_chapter_frames(tag) do
    Enum.filter(tag.frames, fn(%{data: data}) ->
      case data do
        %Id3vx.Frame.Chapter{} -> true
        _ -> false
      end
    end)
  end

  describe "tag_for_episode/1" do
    test "when episode only has a title and subtitle" do
      title = "Ohai this one has some emoj! 🤘"
      episode = build(:episode, title: title)
      tag = Id3.tag_for_episode(episode)

      assert find_text_frame(tag, title)
    end

    test "when episode has subtitle and podcast" do
      subtitle = "with the King of Swing"
      podcast = build(:podcast)
      episode = build(:episode, subtitle: subtitle, podcast: podcast)
      tag = Id3.tag_for_episode(episode)

      assert find_text_frame(tag, podcast.name)
      assert find_text_frame(tag, subtitle)
    end

    # test "when podcast has cover art" do
    # end
  end

  describe "add_chapters/2" do
    test "returns the tag untouched when there aren't any" do
      episode = build(:episode)
      tag = Id3.tag_for_episode(episode)

      assert tag == Id3.add_chapters(tag, [])
    end

    test "returns tag with chapters applied" do
      episode = build(:episode, audio_chapters: [
        build(:episode_chapter, title: "Opener", starts_at: 0.0, ends_at: 100),
        build(:episode_chapter, title: "Middle", starts_at: 0.0, ends_at: 1234, link_url: "https://jsparty.fm"),
        build(:episode_chapter, title: "End", starts_at: 1235.0, ends_at: 9999)
      ])

      tag = Id3.tag_for_episode(episode)
      tag = Id3.add_chapters(tag, episode.audio_chapters)
      chapters = find_chapter_frames(tag)

      assert length(chapters) == 3
    end
  end
end
