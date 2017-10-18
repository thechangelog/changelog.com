defmodule Changelog.EpisodeTopicTest do
  use Changelog.DataCase

  alias Changelog.EpisodeTopic

  describe "changeset" do
    test "valid attributes" do
      changeset = EpisodeTopic.changeset(%EpisodeTopic{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = EpisodeTopic.changeset(%EpisodeTopic{}, %{})
      refute changeset.valid?
    end
  end
end
