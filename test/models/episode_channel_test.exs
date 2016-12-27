defmodule Changelog.EpisodeChannelTest do
  use Changelog.ModelCase

  alias Changelog.EpisodeChannel

  describe "admin_changeset" do
    test "valid attributes" do
      changeset = EpisodeChannel.admin_changeset(%EpisodeChannel{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = EpisodeChannel.admin_changeset(%EpisodeChannel{}, %{})
      refute changeset.valid?
    end
  end
end
