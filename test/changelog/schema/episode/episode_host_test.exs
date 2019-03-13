defmodule Changelog.EpisodeHostTest do
  use Changelog.SchemaCase

  alias Changelog.EpisodeHost

  describe "changeset" do
    test "valid attributes" do
      changeset = EpisodeHost.changeset(%EpisodeHost{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = EpisodeHost.changeset(%EpisodeHost{}, %{})
      refute changeset.valid?
    end
  end
end
