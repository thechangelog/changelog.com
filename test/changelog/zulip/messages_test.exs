defmodule Changelog.Zulip.MessagesTest do
  use ExUnit.Case

  import Changelog.Factory

  alias Changelog.Zulip.Messages

  describe "chapters/1" do
    test "is nil when there are no chapters" do
      assert Messages.chapters([]) == nil
    end

    test "is a markdown table when one chapter exists" do
      ch1 = build(:episode_chapter, title: "Chapter 1", starts_at: 0, ends_at: 0)

      table = """
      | Ch | Start | Title     | Runs  |
      | -- | ----- | --------- | ----- |
      | 01 | 00:00 | Chapter 1 | 00:00 |
      """

      assert Messages.chapters([ch1]) == String.trim_trailing(table, "\n")
    end

    test "is a markdown table when multiple chapter exists" do
      ch1 =
        build(:episode_chapter, title: "Yo that's a rather long title", starts_at: 0, ends_at: 36)

      ch2 = build(:episode_chapter, title: "Go shorty", starts_at: 37, ends_at: 247)

      table = """
      | Ch | Start | Title                         | Runs  |
      | -- | ----- | ----------------------------- | ----- |
      | 01 | 00:00 | Yo that's a rather long title | 00:36 |
      | 02 | 00:37 | Go shorty                     | 03:30 |
      """

      assert Messages.chapters([ch1, ch2]) == String.trim_trailing(table, "\n")
    end

    test "it includes markdown links when chapter has one" do
      ch1 =
        build(:episode_chapter,
          title: "Link me up! This is the longest",
          link_url: "https://link.zelda",
          starts_at: 0,
          ends_at: 36
        )

      ch2 = build(:episode_chapter, title: "No link here...", starts_at: 37, ends_at: 247)

      table = """
      | Ch | Start | Title                           | Runs  |
      | -- | ----- | ------------------------------- | ----- |
      | 01 | 00:00 | [Link me up! This is the longest](https://link.zelda) | 00:36 |
      | 02 | 00:37 | No link here...                 | 03:30 |
      """

      assert Messages.chapters([ch1, ch2]) == String.trim_trailing(table, "\n")
    end
  end
end
