defmodule Changelog.Zulip.MessagesTest do
  use ExUnit.Case

  import Mock
  import Changelog.Factory

  alias Changelog.Zulip.Messages

  describe "chapters/1" do
    setup_with_mocks([
      {ChangelogWeb.EpisodeView, [], [share_url: fn _ -> "https://cpu.fm/1" end]}
    ]) do
      :ok
    end

    test "is nil when there are no chapters" do
      episode = build(:episode, audio_chapters: [])
      assert Messages.chapters(episode) == nil
    end

    test "is a markdown table when one chapter exists" do
      ch1 = build(:episode_chapter, title: "Chapter 1", starts_at: 0, ends_at: 0)
      episode = build(:episode, audio_chapters: [ch1])

      table = """
      | Ch | Start | Title     | Runs  |
      | -- | ----- | --------- | ----- |
      | 01 | [00:00](https://cpu.fm/1#t=0) | Chapter 1 | 00:00 |
      """

      assert Messages.chapters(episode) == String.trim_trailing(table, "\n")
    end

    test "is a markdown table when multiple chapter exists" do
      ch1 =
        build(:episode_chapter, title: "Yo that's a rather long title", starts_at: 0, ends_at: 36)

      ch2 = build(:episode_chapter, title: "Go shorty", starts_at: 37, ends_at: 247)

      episode = build(:episode, audio_chapters: [ch1, ch2])

      table = """
      | Ch | Start | Title                         | Runs  |
      | -- | ----- | ----------------------------- | ----- |
      | 01 | [00:00](https://cpu.fm/1#t=0) | Yo that's a rather long title | 00:36 |
      | 02 | [00:37](https://cpu.fm/1#t=37) | Go shorty                     | 03:30 |
      """

      assert Messages.chapters(episode) == String.trim_trailing(table, "\n")
    end

    test "it includes markdown links when chapter has one" do
      ch1 =
        build(:episode_chapter,
          title: "Link me up! This is the longest",
          link_url: "https://link.zelda",
          starts_at: 0,
          ends_at: 136
        )

      ch2 = build(:episode_chapter, title: "No link here...", starts_at: 137, ends_at: 247)

      episode = build(:episode, audio_chapters: [ch1, ch2])

      table = """
      | Ch | Start | Title                           | Runs  |
      | -- | ----- | ------------------------------- | ----- |
      | 01 | [00:00](https://cpu.fm/1#t=0) | [Link me up! This is the longest](https://link.zelda) | 02:16 |
      | 02 | [02:17](https://cpu.fm/1#t=137) | No link here...                 | 01:50 |
      """

      assert Messages.chapters(episode) == String.trim_trailing(table, "\n")
    end
  end
end
