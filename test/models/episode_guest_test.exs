defmodule Changelog.EpisodeGuestTest do
  use Changelog.ModelCase

  alias Changelog.EpisodeGuest

  describe "changeset" do
    test "valid attributes" do
      changeset = EpisodeGuest.changeset(%EpisodeGuest{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = EpisodeGuest.changeset(%EpisodeGuest{}, %{})
      refute changeset.valid?
    end
  end
end
