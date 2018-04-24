defmodule Changelog.Github.UpdaterTest do
  use Changelog.DataCase

  import Mock

  alias Changelog.Github.{Source, Updater}

  describe "update" do
    test "fetches show notes for valid episode" do
      p = insert(:podcast, slug: "jsparty")
      e = insert(:published_episode, slug: "12", podcast: p)

      with_mock HTTPoison, [get!: fn(_) -> "markdown" end] do
        Updater.update(e, "show-notes")
        assert called HTTPoison.get!(Source.new("show-notes", e).raw_url)
      end
    end

    test "fetches multiple transcripts for valid episodes" do
      p = insert(:podcast, slug: "podcast")
      e1 = insert(:published_episode, slug: "292", podcast: p)
      e2 = insert(:published_episode, slug: "300", podcast: p)

      with_mock HTTPoison, [get!: fn(_) -> "markdown" end] do
        Updater.update([e1, e2], "transcripts")
        assert called HTTPoison.get!(Source.new("transcripts", e1).raw_url)
        assert called HTTPoison.get!(Source.new("transcripts", e2).raw_url)
      end
    end

    test "fetches transcript for valid path" do
      p = insert(:podcast, slug: "rfc")
      e = insert(:published_episode, slug: "test", podcast: p)

      with_mock HTTPoison, [get!: fn(_) -> "markdown" end] do
        Updater.update("rfc/request-for-commits-test.md", "transcripts")
        assert called HTTPoison.get!(Source.new("transcripts", e).raw_url)
      end
    end

    test "fetches multiple show notes for valid paths" do
      p = insert(:podcast, slug: "podcast")
      e1 = insert(:published_episode, slug: "292", podcast: p)
      e2 = insert(:published_episode, slug: "300", podcast: p)

      with_mock HTTPoison, [get!: fn(_) -> "markdown" end] do
        Updater.update(["podcast/the-changelog-292.md", "podcast/the-changelog-300.md"], "show-notes")
        assert called HTTPoison.get!(Source.new("show-notes", e1).raw_url)
        assert called HTTPoison.get!(Source.new("show-notes", e2).raw_url)
      end
    end

    test "no-ops when items are not valid episodes" do
      with_mock HTTPoison, [get!: fn(_) -> "markdown" end] do
        Updater.update([".gitignore", "README.md"], "transcripts")
        refute called HTTPoison.get!()
      end
    end
  end
end
