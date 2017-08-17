defmodule Changelog.EpisodeTest do
  use Changelog.ModelCase

  alias Changelog.Episode

  describe "admin_changeset" do
    test "with valid attributes" do
      changeset = Episode.admin_changeset(%Episode{}, %{slug: "181", title: "some content"})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Episode.admin_changeset(%Episode{}, %{})
      refute changeset.valid?
    end
  end

  describe "validating featured episodes" do
    test "featured changeset that is missing a highlight" do
      changeset = Episode.admin_changeset(build(:episode), %{featured: true})
      refute changeset.valid?
    end

    test "featured changeset that includes a highlight" do
      changeset = Episode.admin_changeset(build(:episode), %{featured: true, highlight: "Much wow"})
      assert changeset.valid?
    end
  end

  test "with_numbered_slug" do
    insert :episode, slug: "bonus-episode-dont-find-me"

    yes1 = insert :episode, slug: "204"
    yes2 = insert :episode, slug: "99"

    found_titles =
      Episode.with_numbered_slug
      |> Repo.all
      |> Enum.map(&(&1.title))

    assert found_titles == [yes1.title, yes2.title]
  end

  describe "update_stat_counts" do
    test "it defaults to 0 when episode has no imports or stats" do
      episode = insert(:episode, import_count: 0.0)
      episode = Episode.update_stat_counts(episode)
      assert episode.download_count == 0
      assert episode.reach_count == 0
    end

    test "it uses import count when episode has import count but not stats" do
      episode = insert(:episode, import_count: 83.3)
      episode = Episode.update_stat_counts(episode)
      assert episode.download_count == 83.3
    end

    test "it adds together import count and stat downloads counts, sums uniques" do
      episode = insert(:episode, import_count: 98.5)
      insert(:episode_stat, date: ~D[2016-01-01], episode: episode, downloads: 100.75, uniques: 4)
      insert(:episode_stat, date: ~D[2016-01-02], episode: episode, downloads: 84.0, uniques: 45)
      insert(:episode_stat, date: ~D[2016-01-03], episode: episode, downloads: 53.4)
      insert(:episode_stat, downloads: 100.0)
      episode = Episode.update_stat_counts(episode)
      assert episode.download_count == 98.5+100.75+84+53.4
      assert episode.reach_count == 4+45
    end
  end

  describe "search" do
    setup do
      {:ok, phoenix: insert(:published_episode, slug: "phoenix-episode", title: "Phoenix", summary: "A web framework for Elixir", notes: "Chris McCord"),
            rails: insert(:published_episode, slug: "rails-episode", title: "Rails", summary: "A web framework for Ruby", notes: "DHH") }
    end

    test "finds episode by matching title" do
      episode_titles =
        Episode
        |> Episode.search("Rails")
        |> Repo.all
        |> Enum.map(&(&1.title))

      assert episode_titles == ["Rails"]
    end

    test "finds episode by matching summary" do
      episode_titles =
        Episode
        |> Episode.search("Elixir")
        |> Repo.all
        |> Enum.map(&(&1.title))

      assert episode_titles == ["Phoenix"]
    end

    test "finds episode by matching notes" do
      episode_titles =
        Episode
        |> Episode.search("McCord")
        |> Repo.all
        |> Enum.map(&(&1.title))

      assert episode_titles == ["Phoenix"]
    end
  end

  describe "is_publishable" do
    test "is false when episode is missing required fields" do
      refute Episode.is_publishable(build(:episode))
    end

    test "is false when episode is published" do
      refute Episode.is_publishable(build(:published_episode))
    end

    test "is true when episode has all fields and isn't published" do
      assert Episode.is_publishable(stub_audio_file(build(:publishable_episode)))
    end
  end
end
