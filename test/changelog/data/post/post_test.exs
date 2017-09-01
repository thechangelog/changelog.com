defmodule Changelog.PostTest do
  use Changelog.DataCase

  alias Changelog.Post

  describe "admin_changeset" do
    test "with valid attributes" do
      changeset = Post.admin_changeset(%Post{}, %{slug: "what-a-post", title: "What a Post", author_id: 42})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Post.admin_changeset(%Post{}, %{title: "What a Post"})
      refute changeset.valid?
    end
  end

  describe "search" do
    setup do
      {:ok, phoenix: insert(:published_post, slug: "phoenix-post", title: "Phoenix", tldr: "A web framework for Elixir", body: "Chris McCord"),
            rails: insert(:published_post, slug: "rails-post", title: "Rails", tldr: "A web framework for Ruby", body: "DHH") }
    end

    test "finds post by matching title" do
      post_titles =
        Post
        |> Post.search("Phoenix")
        |> Repo.all
        |> Enum.map(&(&1.title))

      assert post_titles == ["Phoenix"]
    end

    test "finds post by matching tldr" do
      post_titles =
        Post
        |> Post.search("Ruby")
        |> Repo.all
        |> Enum.map(&(&1.title))

      assert post_titles == ["Rails"]
    end

    test "finds post by matching body" do
      post_titles =
        Post
        |> Post.search("DHH")
        |> Repo.all
        |> Enum.map(&(&1.title))

      assert post_titles == ["Rails"]
    end
  end
end
