defmodule Changelog.FeedTest do
  use Changelog.SchemaCase

  alias Changelog.Feed

  @valid_attrs %{name: "Custom Feed", owner_id: 1}
  @invalid_attrs %{}

  test "insert_changeset/2 with valid attributes" do
    changeset = Feed.insert_changeset(%Feed{}, @valid_attrs)
    assert changeset.valid?
  end

  test "insert_changeset/2 with invalid attributes" do
    changeset = Feed.insert_changeset(%Feed{}, @invalid_attrs)
    refute changeset.valid?
  end
end
