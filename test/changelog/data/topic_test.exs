defmodule Changelog.TopicTest do
  use Changelog.DataCase

  alias Changelog.Topic

  describe "admin_changeset" do
    test "with valid attributes" do
      changeset = Topic.admin_changeset(%Topic{}, %{name: "Ruby on Rails", slug: "ruby-on-rails"})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = Topic.admin_changeset(%Topic{}, %{})
      refute changeset.valid?
    end
  end
end
