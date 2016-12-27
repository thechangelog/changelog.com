defmodule Changelog.PodcastHostTest do
  use Changelog.ModelCase

  alias Changelog.PodcastHost

  describe "admin_changeset" do
    test "valid attributes" do
      changeset = PodcastHost.admin_changeset(%PodcastHost{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = PodcastHost.admin_changeset(%PodcastHost{}, %{})
      refute changeset.valid?
    end
  end
end
