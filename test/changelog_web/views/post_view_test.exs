defmodule ChangelogWeb.PostViewTest do
  use ChangelogWeb.ConnCase, async: true

  import ChangelogWeb.PostView

  describe "paragraph_count/1" do
    test "it works with markdown" do
      post = build(:post, body: "ohai\n\nthere\n\nwhat do you think")
      assert paragraph_count(post) == 3
    end

    test "it works with html" do
      post = build(:post, body: "<p>oahi</p><p>there</p>")
      assert paragraph_count(post) == 2
    end
  end
end
