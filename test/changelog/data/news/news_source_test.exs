defmodule Changelog.NewsSourceTest do
  use Changelog.DataCase

  alias Changelog.NewsSource

  describe "admin_changeset" do
    test "with valid attributes" do
      changeset = NewsSource.admin_changeset(%NewsSource{}, %{name: "GitHub", slug: "github", website: "https://github.com"})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = NewsSource.admin_changeset(%NewsSource{}, %{})
      refute changeset.valid?
    end
  end
end
