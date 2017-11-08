defmodule Changelog.NewsItemTest do
  use Changelog.DataCase

  alias Changelog.NewsItem

  describe "insert_changeset" do
    test "with valid attributes" do
      changeset = NewsItem.insert_changeset(%NewsItem{}, %{status: :queued, type: :link, url: "https://github.com/blog/ohai-there", headline: "Big NEWS!", logger_id: 1})
      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = NewsItem.insert_changeset(%NewsItem{}, %{})
      refute changeset.valid?
    end
  end
end
