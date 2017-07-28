defmodule Changelog.Transcripts.UpdaterTest do
  use Changelog.ModelCase

  import Mock

  alias Changelog.Transcripts.{Source, Updater}

  describe "update" do
    test "fetches transcript for valid episode" do
      p = insert(:podcast, slug: "jsparty")
      e = insert(:published_episode, slug: "12", podcast: p)

      with_mock HTTPoison, [get!: fn(_) -> "markdown" end] do
        Updater.update(e)
        assert called HTTPoison.get!(Source.raw_url(e))
      end
    end

    test "fetches multiple transcript for valid episodes" do
      p = insert(:podcast, slug: "podcast")
      e1 = insert(:published_episode, slug: "292", podcast: p)
      e2 = insert(:published_episode, slug: "300", podcast: p)

      with_mock HTTPoison, [get!: fn(_) -> "markdown" end] do
        Updater.update([e1, e2])
        assert called HTTPoison.get!(Source.raw_url(e1))
        assert called HTTPoison.get!(Source.raw_url(e2))
      end
    end

    test "fetches transcript for valid path" do
      p = insert(:podcast, slug: "rfc")
      e = insert(:published_episode, slug: "test", podcast: p)

      with_mock HTTPoison, [get!: fn(_) -> "markdown" end] do
        Updater.update("rfc/request-for-commits-test.md")
        assert called HTTPoison.get!(Source.raw_url(e))
      end
    end

    test "fetches multiple transcript for valid paths" do
      p = insert(:podcast, slug: "podcast")
      e1 = insert(:published_episode, slug: "292", podcast: p)
      e2 = insert(:published_episode, slug: "300", podcast: p)

      with_mock HTTPoison, [get!: fn(_) -> "markdown" end] do
        Updater.update(["podcast/the-changelog-292.md", "podcast/the-changelog-300.md"])
        assert called HTTPoison.get!(Source.raw_url(e1))
        assert called HTTPoison.get!(Source.raw_url(e2))
      end
    end
  end
end
