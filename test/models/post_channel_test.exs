defmodule Changelog.PostChannelTest do
  use Changelog.ModelCase

  alias Changelog.PostChannel

  @valid_attrs %{position: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = PostChannel.changeset(%PostChannel{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = PostChannel.changeset(%PostChannel{}, @invalid_attrs)
    refute changeset.valid?
  end
end
