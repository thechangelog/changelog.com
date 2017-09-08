defmodule Changelog.NewsItemTest do
  use Changelog.DataCase

  alias Changelog.NewsItem

  describe "admin_changeset" do
    test "with valid attributes" do
      changeset = NewsItem.admin_changeset(%NewsItem{}, %{status: :queued, type: :link, url: "https://github.com/blog/ohai-there", headline: "Big NEWS!", author_id: 1})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = NewsItem.admin_changeset(%NewsItem{}, %{})
      refute changeset.valid?
    end
  end
end
