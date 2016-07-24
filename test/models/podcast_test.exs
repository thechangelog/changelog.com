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
end
