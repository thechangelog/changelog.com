defmodule Changelog.EpisodeTest do
  use Changelog.ModelCase

  alias Changelog.Episode

  @valid_attrs %{slug: "181", title: "some content"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Episode.changeset(%Episode{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Episode.changeset(%Episode{}, @invalid_attrs)
    refute changeset.valid?
  end

  describe "validating featured episodes" do
    test "featured changeset that is missing a highlight" do
      changeset = Episode.changeset(build(:episode), %{featured: true})
      refute changeset.valid?
    end

    test "featured changeset that includes a highlight" do
      changeset = Episode.changeset(build(:episode), %{featured: true, highlight: "Much wow"})
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
end
