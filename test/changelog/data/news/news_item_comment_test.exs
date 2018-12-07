defmodule Changelog.NewsItemCommentTest do
  use Changelog.DataCase

  alias Changelog.NewsItemComment

  describe "insert_changeset" do
    test "with valid attributes" do
      changeset = NewsItemComment.insert_changeset(%NewsItemComment{}, %{content: "ohai", item_id: 1, author_id: 2})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = NewsItemComment.insert_changeset(%NewsItemComment{}, %{content: "ohnoes"})
      refute changeset.valid?
    end
  end
end
