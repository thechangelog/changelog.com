defmodule Changelog.PostChannelTest do
  use Changelog.ModelCase

  alias Changelog.PostChannel

  describe "admin_changeset" do
    test "valid attributes" do
      changeset = PostChannel.admin_changeset(%PostChannel{}, %{position: 42})
      assert changeset.valid?
    end

    test "invalid attributes" do
      changeset = PostChannel.admin_changeset(%PostChannel{}, %{})
      refute changeset.valid?
    end
  end
end
