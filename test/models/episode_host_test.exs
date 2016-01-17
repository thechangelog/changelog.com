defmodule Changelog.EpisodeHostTest do
  use Changelog.ModelCase

  alias Changelog.EpisodeHost

  @valid_attrs %{position: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EpisodeHost.changeset(%EpisodeHost{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EpisodeHost.changeset(%EpisodeHost{}, @invalid_attrs)
    refute changeset.valid?
  end
end
