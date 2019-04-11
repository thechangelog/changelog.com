defmodule ChangelogWeb.Meta.CanonicalUrlTest do
  use ExUnit.Case

  import ChangelogWeb.Meta.CanonicalUrl

  alias ChangelogWeb.PostView

  describe "canonical_url/1" do
    test "when post view with a canonical url assigned" do
      post = %{canonical_url: "https://ohai-there.com/okthxbai"}
      url = canonical_url(%{view_module: PostView, post: post})
      assert url == post.canonical_url
    end

    test "when post view but no canonical url assigned" do
      post = %{}
      url = canonical_url(%{view_module: PostView, post: post})
      assert is_nil(url)
    end

    test "when not on post view" do
      url = canonical_url(%{})
      assert is_nil(url)
    end
  end
end
