defmodule Changelog.Mp3KitTest do
  use Changelog.SchemaCase

  alias Changelog.Mp3Kit

  describe "get_duration/1" do
    test "works when given a path to an mp3" do
      path = fixtures_path("/california.mp3")
      assert Mp3Kit.get_duration(path) == 179
    end

    test "works when directly given mp3 data" do
      {:ok, data} = File.read(fixtures_path("/california.mp3"))
      assert Mp3Kit.get_duration(data) == 179
    end
  end

  describe "tag_for_episode/1" do
    test "when episode only has a title and subtitle" do
      title = "Ohai this one has some emoj! 🤘"
      episode = build(:episode, title: title)
      tag = Mp3Kit.tag_for_episode(episode)

      assert find_text_frame(tag, title)
    end

    test "when episode has subtitle and podcast" do
      subtitle = "with the King of Swing"
      podcast = build(:podcast)
      episode = build(:episode, subtitle: subtitle, podcast: podcast)
      tag = Mp3Kit.tag_for_episode(episode)

      assert find_text_frame(tag, podcast.name)
      assert find_text_frame(tag, subtitle)
    end

    test "when episode has a published_at time" do
      episode = build(:episode, published_at: ~D[2022-09-02])
      tag = Mp3Kit.tag_for_episode(episode)

      assert find_text_frame(tag, "2022")
      assert find_text_frame(tag, "0209")
    end
  end

  describe "add_chapters_to_tag/2" do
    test "returns the tag with no chapter frames when passed none" do
      chapters =
        build(:episode)
        |> Mp3Kit.tag_for_episode()
        |> Mp3Kit.add_chapters_to_tag([])
        |> find_chapter_frames()

      assert length(chapters) == 0
    end

    test "returns the tag with chapter frames applied" do
      episode = build(:episode, audio_chapters: [
        build(:episode_chapter, title: "Opener", starts_at: 0.0, ends_at: 100),
        build(:episode_chapter, title: "Middle", starts_at: 0.0, ends_at: 1234, link_url: "https://jsparty.fm"),
        build(:episode_chapter, title: "End", starts_at: 1235.0, ends_at: 9999)
      ])

      chapters =
        episode
        |> Mp3Kit.tag_for_episode()
        |> Mp3Kit.add_chapters_to_tag(episode.audio_chapters)
        |> find_chapter_frames()

      assert length(chapters) == 3
    end
  end

  describe "add_date_to_tag/2" do
    test "when date is nil" do
      tag = Id3vx.Tag.create(3)
      assert Mp3Kit.add_date_to_tag(tag, nil) == tag
    end

    test "when date is valid" do
      tag = Id3vx.Tag.create(3)
      tag = Mp3Kit.add_date_to_tag(tag, ~D[2011-01-02])
      assert find_text_frame(tag, "2011")
      assert find_text_frame(tag, "0201")
    end
  end

  describe "add_image_to_tag/2" do
    test "when valid image path is provided" do
      file_path = fixtures_path("/images/avatar600x600.png")

      tag =
        build(:episode)
        |> Mp3Kit.tag_for_episode()
        |> Mp3Kit.add_image_to_tag(file_path)

      assert length(find_picture_frames(tag)) == 1
    end
  end

  def find_chapter_frames(tag) do
    Enum.filter(tag.frames, fn(%{data: data}) ->
      case data do
        %Id3vx.Frame.Chapter{} -> true
        _ -> false
      end
    end)
  end

  def find_picture_frames(tag) do
    Enum.filter(tag.frames, fn(%{data: data}) ->
      case data do
        %Id3vx.Frame.AttachedPicture{} -> true
        _ -> false
      end
    end)
  end

  def find_text_frame(tag, text) do
    Enum.find(tag.frames, fn(f) -> Enum.member?(f.data.text, text) end)
  end
end
