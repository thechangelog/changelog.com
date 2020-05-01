defmodule Changelog.NewsAdTest do
  use Changelog.SchemaCase

  alias Changelog.NewsAd

  describe "changeset" do
    test "with valid attributes" do
      changeset =
        NewsAd.changeset(%NewsAd{}, %{
          url: "https://github.com/blog/ohai-there",
          headline: "Big NEWS!"
        })

      assert changeset.valid?
    end

    test "with invalid attributes" do
      changeset = NewsAd.changeset(%NewsAd{}, %{headline: "Big NEWS!"})
      refute changeset.valid?
    end
  end
end
