defmodule Changelog.NewsItemCommentTest do
  use Changelog.SchemaCase

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

  describe "mentioned_people/1" do
    test "returns an empty list when there aren't any mentions" do
      comment = build(:news_item_comment, content: "zomg this is rad")
      assert NewsItemComment.mentioned_people(comment) == []
    end

    test "also works directly with comment content" do
      assert NewsItemComment.mentioned_people("zomg this is rad") == []
    end

    test "returns one person when they are mentioned" do
      person = insert(:person, handle: "joeblow")
      comment = build(:news_item_comment, content: "zomg @joeblow this is rad")
      assert NewsItemComment.mentioned_people(comment) == [person]
    end

    @tag skip: "this test is racey and fails intermittently"
    test "returns many people when they are mentioned" do
      p1 = insert(:person, handle: "joeblow")
      p2 = insert(:person, handle: "janeblow")
      p3 = insert(:person, handle: "aliceblow")
      comment = build(:news_item_comment, content: "zomg @joeblow & @janeblow this is rad @aliceblow!")
      assert NewsItemComment.mentioned_people(comment) == [p1, p2, p3]
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
