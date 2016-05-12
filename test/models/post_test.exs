defmodule Changelog.PostTest do
  use Changelog.ModelCase

  alias Changelog.Post

  @valid_attrs %{slug: "what-a-post", title: "What a Post"}
  @invalid_attrs %{title: "What a Post"}

  test "changeset with valid attributes" do
    changeset = Post.changeset(%Post{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Post.changeset(%Post{}, @invalid_attrs)
    refute changeset.valid?
  end
end
