defmodule Changelog.TopicTest do
  use Changelog.SchemaCase

  alias Changelog.Topic

  describe "insert_changeset" do
    test "with valid attributes" do
      changeset =
        Topic.insert_changeset(%Topic{}, %{name: "Ruby on Rails", slug: "ruby-on-rails"})

      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Topic.insert_changeset(%Topic{}, %{})
      refute changeset.valid?
    end
  end
end
