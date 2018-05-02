defmodule ChangelogWeb.PodcastViewTest do
  use ChangelogWeb.ConnCase, async: true

  import ChangelogWeb.PodcastView

  describe "subscribe_on_overcast_url" do
    test "reformats the iTunes URL as necessary" do
      p = build(:podcast, itunes_url: "https://itunes.apple.com/us/podcast/the-changelog/id341623264")
      assert subscribe_on_overcast_url(p) == "https://overcast.fm/itunes341623264/the-changelog"
    end
  end

  describe "subscribe_on_android_url" do
    test "reformats the feed URL as necessary" do
      p = build(:podcast, slug: "ohai")
      assert String.match?(subscribe_on_android_url(p), ~r/\/ohai\/feed\Z/)
    end
  end
end
