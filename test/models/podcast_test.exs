defmodule Changelog.PodcastTest do
  use Changelog.ModelCase

  alias Changelog.Podcast

  @valid_attrs %{slug: "the-bomb-show", name: "The Bomb Show", status: :draft}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Podcast.changeset(%Podcast{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Podcast.changeset(%Podcast{}, @invalid_attrs)
    refute changeset.valid?
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

  describe "update_download_count" do
    setup do
      {:ok, podcast: insert(:podcast)}
    end

    test "it is 0 when podcast has no episodes/downloads", %{podcast: podcast} do
      podcast = Podcast.update_download_count(podcast)
      assert podcast.download_count == 0
    end

    test "it is the sum of episode downloads when there are some", %{podcast: podcast} do
      insert(:episode, download_count: 845.34, podcast: podcast)
      insert(:episode, download_count: 1095.38, podcast: podcast)
      insert(:episode, download_count: 50.5)

      podcast = Podcast.update_download_count(podcast)

      assert podcast.download_count == 1940.72
    end
  end
end
