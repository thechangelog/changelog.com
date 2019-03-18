defmodule Changelog.PodcastTopicTest do
  use Changelog.SchemaCase

  alias Changelog.PodcastTopic

  describe "changeset" do
    test "valid attributes" do
      changeset = PodcastTopic.changeset(%PodcastTopic{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = PodcastTopic.changeset(%PodcastTopic{}, %{})
      refute changeset.valid?
    end
  end
end
