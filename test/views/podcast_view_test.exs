defmodule Changelog.PodcastViewTest do
  use Changelog.ConnCase, async: true

  import Changelog.PodcastView

  test "dasherized_name" do
    assert dasherized_name(build(:podcast, name: "The Changelog")) == "the-changelog"
    assert dasherized_name(build(:podcast, name: "Go Time")) == "go-time"
    assert dasherized_name(build(:podcast, name: "Hell's Kitchen!")) == "hells-kitchen"
  end

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
