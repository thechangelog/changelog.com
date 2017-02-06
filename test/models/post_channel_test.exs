defmodule Changelog.PostChannelTest do
  use Changelog.ModelCase

  alias Changelog.PostChannel

  describe "changeset" do
    test "valid attributes" do
      changeset = PostChannel.changeset(%PostChannel{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = PostChannel.changeset(%PostChannel{}, %{})
      refute changeset.valid?
    end
  end
end
