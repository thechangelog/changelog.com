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

  describe "nested/1" do
    test "nests comments appropriately" do
      parent = %{id: 1, parent_id: nil, content: "ohai"}
      reply = %{id: 2, parent_id: 1, content: "bai now"}

      nested = NewsItemComment.nested([reply, parent])

      assert length(nested) == 1
      assert length(List.first(nested).children) == 1
    end
  end
end
