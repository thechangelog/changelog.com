defmodule ChangelogWeb.PodcastViewTest do
  use ChangelogWeb.ConnCase, async: true

  alias ChangelogWeb.PodcastView

  describe "subscribe_on_overcast_url" do
    test "reformats the Apple URL as necessary" do
      p =
        build(:podcast, apple_url: "https://itunes.apple.com/us/podcast/the-changelog/id341623264")

      assert PodcastView.subscribe_on_overcast_url(p) ==
               "https://overcast.fm/itunes341623264/the-changelog"
    end
  end

  describe "subscribe_on_android_url" do
    test "reformats the feed URL as necessary" do
      p = build(:podcast, slug: "ohai")
      assert String.match?(PodcastView.subscribe_on_android_url(p), ~r/\/ohai\/feed\Z/)
    end
  end
end
