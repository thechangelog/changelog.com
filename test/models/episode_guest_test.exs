defmodule Changelog.EpisodeGuestTest do
  use Changelog.ModelCase

  alias Changelog.EpisodeGuest

  @valid_attrs %{position: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = EpisodeGuest.changeset(%EpisodeGuest{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = EpisodeGuest.changeset(%EpisodeGuest{}, @invalid_attrs)
    refute changeset.valid?
  end
end
