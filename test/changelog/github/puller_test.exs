defmodule Changelog.Github.PullerTest do
  use Changelog.DataCase

  import Mock

  alias Changelog.Github.{Source, Puller}

  describe "update" do
    test "fetches show notes for valid episode" do
      p = insert(:podcast, slug: "jsparty")
      e = insert(:published_episode, slug: "12", podcast: p)

      with_mock(HTTPoison, [get!: fn(_) -> %{status_code: 200, body: ""} end]) do
        Puller.update("show-notes", e)
        assert called HTTPoison.get!(Source.new("show-notes", e).raw_url)
      end
    end

    test "fetches multiple transcripts for valid episodes" do
      p = insert(:podcast, slug: "podcast")
      e1 = insert(:published_episode, slug: "292", podcast: p)
      e2 = insert(:published_episode, slug: "300", podcast: p)

      with_mock(HTTPoison, [get!: fn(_) -> %{status_code: 200, body: ""} end]) do
        Puller.update("transcripts", [e1, e2])
        assert called HTTPoison.get!(Source.new("transcripts", e1).raw_url)
        assert called HTTPoison.get!(Source.new("transcripts", e2).raw_url)
      end
    end

    test "fetches transcript for valid path" do
      p = insert(:podcast, slug: "rfc", name: "Request For Commits")
      e = insert(:published_episode, slug: "test", podcast: p)

      with_mock(HTTPoison, [get!: fn(_) -> %{status_code: 200, body: ""} end]) do
        Puller.update("transcripts", "rfc/request-for-commits-test.md")
        assert called HTTPoison.get!(Source.new("transcripts", e).raw_url)
      end
    end

    test "fetches multiple transcripts for valid paths" do
      p1 = insert(:podcast, slug: "podcast", name: "The Changelog")
      p2 = insert(:podcast, slug: "gotime", name: "Go Time")
      e1 = insert(:published_episode, slug: "292", podcast: p1)
      e2 = insert(:published_episode, slug: "300", podcast: p1)
      e3 = insert(:published_episode, slug: "bonus-77", podcast: p2)

      with_mock(HTTPoison, [get!: fn(_) -> %{status_code: 200, body: ""} end]) do
        Puller.update("transcripts", ~w(podcast/the-changelog-292.md podcast/the-changelog-300.md gotime/go-time-bonus-77.md))
        assert called HTTPoison.get!(Source.new("transcripts", e1).raw_url)
        assert called HTTPoison.get!(Source.new("transcripts", e2).raw_url)
        assert called HTTPoison.get!(Source.new("transcripts", e3).raw_url)
      end
    end

    test "fetches multiple show notes for valid paths" do
      p = insert(:podcast, slug: "podcast", name: "The Changelog")
      e1 = insert(:published_episode, slug: "292", podcast: p)
      e2 = insert(:published_episode, slug: "300", podcast: p)

      with_mock HTTPoison, [get!: fn(_) -> %{status_code: 200, body: ""} end] do
        Puller.update("show-notes", ~w(podcast/the-changelog-292.md podcast/the-changelog-300.md))
        assert called HTTPoison.get!(Source.new("show-notes", e1).raw_url)
        assert called HTTPoison.get!(Source.new("show-notes", e2).raw_url)
      end
    end

    test "no-ops when items are not valid episodes" do
      with_mock(HTTPoison, [get!: fn(_) -> %{status_code: 200, body: ""} end]) do
        Puller.update("transcripts", ~w(.gitignore README.md))
        refute called HTTPoison.get!()
      end
    end
  end
end
