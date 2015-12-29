defmodule Changelog.PodcastHostTest do
  use Changelog.ModelCase

  alias Changelog.PodcastHost

  @valid_attrs %{position: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PodcastHost.changeset(%PodcastHost{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PodcastHost.changeset(%PodcastHost{}, @invalid_attrs)
    refute changeset.valid?
  end
end
