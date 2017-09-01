defmodule Changelog.PodcastTest do
  use Changelog.DataCase

  alias Changelog.Podcast

  describe "admin_changeset" do
    test "with valid attributes" do
      changeset = Podcast.admin_changeset(%Podcast{}, %{slug: "the-bomb-show", name: "The Bomb Show", status: :draft})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Podcast.admin_changeset(%Podcast{}, %{})
      refute changeset.valid?
    end
  end

  test "episode_count returns count of associated eps" do
    podcast = insert :podcast
    assert Podcast.episode_count(podcast) == 0
    insert :published_episode, podcast: podcast
    insert :episode, podcast: podcast
    assert Podcast.episode_count(podcast) == 2
  end

  test "published_episode_count returns count of associated published eps" do
    podcast = insert :podcast
    assert Podcast.published_episode_count(podcast) == 0
    insert :published_episode, podcast: podcast
    insert :episode, podcast: podcast
    assert Podcast.published_episode_count(podcast) == 1
  end

  describe "update_stat_counts" do
    setup do
      {:ok, podcast: insert(:podcast)}
    end

    test "it is 0 when podcast has no episodes/downloads", %{podcast: podcast} do
      podcast = Podcast.update_stat_counts(podcast)
      assert podcast.download_count == 0
    end

    test "it is the sum of episode downloads, reach when there are some", %{podcast: podcast} do
      insert(:episode, download_count: 845.34, reach_count: 33, podcast: podcast)
      insert(:episode, download_count: 1095.38, reach_count: 232, podcast: podcast)
      insert(:episode, download_count: 50.5, reach_count: 123)

      podcast = Podcast.update_stat_counts(podcast)

      assert podcast.download_count == 1940.72
      assert podcast.reach_count == 265
    end
  end
end
