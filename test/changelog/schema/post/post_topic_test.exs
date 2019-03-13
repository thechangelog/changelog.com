defmodule Changelog.PostTopicTest do
  use Changelog.SchemaCase

  alias Changelog.PostTopic

  describe "changeset" do
    test "valid attributes" do
      changeset = PostTopic.changeset(%PostTopic{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = PostTopic.changeset(%PostTopic{}, %{})
      refute changeset.valid?
    end
  end
end
