defmodule Changelog.TopicTest do
  use Changelog.ModelCase

  alias Changelog.Topic

  @valid_attrs %{name: "Ruby on Rails", slug: "ruby-on-rails"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Topic.changeset(%Topic{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Topic.changeset(%Topic{}, @invalid_attrs)
    refute changeset.valid?
  end
end
