defmodule Changelog.EpisodeLinkTest do
  use Changelog.ModelCase

  alias Changelog.EpisodeLink

  @valid_attrs %{position: 1, url: "https://changelog.com", title: "test"}
  @invalid_attrs %{url: ""}

  test "changeset with valid attributes" do
    changeset = EpisodeLink.changeset(%EpisodeLink{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EpisodeLink.changeset(%EpisodeLink{}, @invalid_attrs)
    refute changeset.valid?
  end
end
