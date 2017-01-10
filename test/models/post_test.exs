defmodule Changelog.PostTest do
  use Changelog.ModelCase

  alias Changelog.Post

  @valid_attrs %{slug: "what-a-post", title: "What a Post", author_id: 42}
  @invalid_attrs %{title: "What a Post"}

  test "changeset with valid attributes" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
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
