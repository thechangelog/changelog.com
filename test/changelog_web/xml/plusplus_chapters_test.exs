defmodule ChangelogWeb.Xml.PlusplusChaptersTest do
  use ChangelogWeb.ConnCase, async: true

  alias ChangelogWeb.Xml.{Feed, Plusplus}

  # The Changelog++ premium RSS feed (`Xml.Plusplus`) and the PlusPlus-enabled
  # personalized feed (`Xml.Feed` with `plusplus: true`) each have a `chapters`
  # helper that emits `<podcast:chapters>` + inline `<psc:chapters>`, preferring
  # `plusplus_chapters` over `audio_chapters` when a `plusplus_file` exists.
  #
  # A prior guard `defp chapters(%{audio_chapters: []}), do: nil` (copied from the
  # public `podcast.ex`, where it is correct) suppressed ALL chapter data whenever
  # `audio_chapters` was empty — even when `plusplus_chapters` was non-empty.
  # These tests pin the guard clauses so that regression cannot silently return,
  # and so the precise two-clause guard isn't simplified back to a single field
  # (which would leak an empty `<podcast:chapters>` link for audio-only items).
  describe "Xml.Plusplus.item/2 chapters" do
    test "emits PlusPlus chapters when audio_chapters is empty but plusplus_chapters is present" do
      episode = episode(audio_chapters: [], plusplus_chapters: [chapter("Intro++", 0)])

      xml = render(Plusplus.item(episode.podcast, episode))

      assert has_podcast_chapters?(xml)
      assert points_to_plusplus_chapters?(xml)
      assert has_psc_chapters?(xml)
      assert xml =~ "Intro++"
    end

    test "emits no chapters when both chapter lists are empty" do
      episode = episode(audio_chapters: [], plusplus_chapters: [])

      xml = render(Plusplus.item(episode.podcast, episode))

      refute has_podcast_chapters?(xml)
      refute has_psc_chapters?(xml)
    end

    test "emits no chapters for an audio-only episode with stray plusplus_chapters but no plusplus_file" do
      episode =
        episode(
          audio_chapters: [],
          plusplus_chapters: [chapter("Intro++", 0)],
          plusplus_file: nil
        )

      xml = render(Plusplus.item(episode.podcast, episode))

      refute has_podcast_chapters?(xml)
      refute has_psc_chapters?(xml)
      refute xml =~ "Intro++"
    end
  end

  describe "Xml.Feed.item/2 chapters for a PlusPlus-enabled feed" do
    test "emits PlusPlus chapters when audio_chapters is empty but plusplus_chapters is present" do
      feed = feed(plusplus: true)
      episode = episode(audio_chapters: [], plusplus_chapters: [chapter("Intro++", 0)])

      xml = render(Feed.item(feed, episode))

      assert has_podcast_chapters?(xml)
      assert points_to_plusplus_chapters?(xml)
      assert has_psc_chapters?(xml)
      assert xml =~ "Intro++"
    end

    test "emits no chapters when both chapter lists are empty" do
      feed = feed(plusplus: true)
      episode = episode(audio_chapters: [], plusplus_chapters: [])

      xml = render(Feed.item(feed, episode))

      refute has_podcast_chapters?(xml)
      refute has_psc_chapters?(xml)
    end
  end

  describe "Xml.Feed.item/2 chapters for a non-PlusPlus feed" do
    test "emits no chapters when audio_chapters is empty, even if plusplus_chapters is present" do
      feed = feed(plusplus: false)
      episode = episode(audio_chapters: [], plusplus_chapters: [chapter("Intro++", 0)])

      xml = render(Feed.item(feed, episode))

      refute has_podcast_chapters?(xml)
      refute has_psc_chapters?(xml)
      refute xml =~ "Intro++"
    end
  end

  defp render(item), do: item |> XmlBuilder.document() |> XmlBuilder.generate()

  defp has_podcast_chapters?(xml), do: String.contains?(xml, "podcast:chapters")
  defp has_psc_chapters?(xml), do: String.contains?(xml, "psc:chapters")
  defp points_to_plusplus_chapters?(xml), do: String.contains?(xml, "?pp=true")

  defp chapter(title, start) do
    %Changelog.EpisodeChapter{title: title, starts_at: start}
  end

  defp feed(overrides) do
    struct(%Changelog.Feed{title_format: nil, plusplus: false}, overrides)
  end

  defp episode(overrides) do
    base = %Changelog.Episode{
      id: 1,
      podcast_id: 1,
      slug: "ep-bug",
      title: "Best Show",
      summary: "A summary",
      notes: "",
      type: :full,
      published_at: nil,
      audio_bytes: 42,
      audio_duration: 1800,
      audio_file: %{file_name: "a.mp3"},
      audio_chapters: [],
      plusplus_file: %{file_name: "p.mp3"},
      plusplus_bytes: 9999,
      plusplus_duration: 1800,
      plusplus_chapters: [],
      hosts: [],
      guests: [],
      episode_sponsors: [],
      podcast: %Changelog.Podcast{
        id: 1,
        slug: "the-changelog",
        name: "The Changelog",
        status: :publishing,
        cover: nil
      }
    }

    struct(base, overrides)
  end
end
