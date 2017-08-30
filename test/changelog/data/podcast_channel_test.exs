defmodule Changelog.PodcastChannelTest do
  use Changelog.DataCase

  alias Changelog.PodcastChannel

  describe "changeset" do
    test "valid attributes" do
      changeset = PodcastChannel.changeset(%PodcastChannel{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = PodcastChannel.changeset(%PodcastChannel{}, %{})
      refute changeset.valid?
    end
  end
end
