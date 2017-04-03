defmodule Changelog.EpisodeChannelTest do
  use Changelog.ModelCase

  alias Changelog.EpisodeChannel

  describe "changeset" do
    test "valid attributes" do
      changeset = EpisodeChannel.changeset(%EpisodeChannel{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = EpisodeChannel.changeset(%EpisodeChannel{}, %{})
      refute changeset.valid?
    end
  end
end
