defmodule Changelog.NewsSourceTest do
  use Changelog.SchemaCase

  alias Changelog.NewsSource

  describe "insert_changeset" do
    test "with valid attributes" do
      changeset = NewsSource.insert_changeset(%NewsSource{}, %{name: "GitHub", slug: "github", website: "https://github.com"})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = NewsSource.insert_changeset(%NewsSource{}, %{})
      refute changeset.valid?
    end
  end
end
