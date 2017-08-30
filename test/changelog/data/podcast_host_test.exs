defmodule Changelog.PodcastHostTest do
  use Changelog.DataCase

  alias Changelog.PodcastHost

  describe "changeset" do
    test "valid attributes" do
      changeset = PodcastHost.changeset(%PodcastHost{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = PodcastHost.changeset(%PodcastHost{}, %{})
      refute changeset.valid?
    end
  end
end
