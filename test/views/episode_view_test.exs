defmodule Changelog.EpisodeViewTest do
  use Changelog.ConnCase, async: true

  import Changelog.EpisodeView
  alias Changelog.Episode

  test "megabtyes" do
    assert megabytes(%Episode{bytes: 1000}) == 0
    assert megabytes(%Episode{bytes: 1_000_000}) == 1
    assert megabytes(%Episode{bytes: 68_530_176}) == 69
  end

  describe "number" do
    test "it is empty when slug is not a number" do
      assert number(build(:episode, slug: "not-a-number")) == nil
    end

    test "it is the slug when slug is a number" do
      assert number(build(:episode, slug: "211")) == "211"
    end
  end

  describe "numbered_title" do
    test "it has number but no pound by default when episode has number" do
      ep = build(:episode, slug: "1", title: "Test")
      assert numbered_title(ep) == "1: Test"
    end

    test "it includes a prefix passed in when episode has number" do
      ep = build(:episode, slug: "1", title: "Test")
      assert numbered_title(ep, "#") == "#1: Test"
    end

    test "it has just the episode title when episode has no number" do
      ep = build(:episode, slug: "bonus-ep", title: "Test")
      assert numbered_title(ep, "#") == "Test"
    end
  end
end
