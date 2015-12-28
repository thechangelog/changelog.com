defmodule Changelog.PodcastTest do
  use Changelog.ModelCase

  alias Changelog.Podcast

  @valid_attrs %{slug: "the-bomb-show", name: "The Bomb Show"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Podcast.changeset(%Podcast{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Podcast.changeset(%Podcast{}, @invalid_attrs)
    refute changeset.valid?
  end
end
