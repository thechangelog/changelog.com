defmodule ChangelogWeb.PodcastViewTest do
  use ChangelogWeb.ConnCase, async: true

  alias ChangelogWeb.PodcastView

  describe "dasherized_name/1" do
    test "represents as The Changelog when called on the Interviews pod" do
      p = build(:podcast, name: "Changelog Interviews")
      assert PodcastView.dasherized_name(p) == "the-changelog"
    end

    test "takes the podcast name and dasherizes it" do
      p = build(:podcast, name: "A Test Pod")
      assert PodcastView.dasherized_name(p) == "a-test-pod"
    end
  end

  describe "subscribe_on_overcast_url" do
    test "reformats the Apple URL as necessary" do
      p =
        build(:podcast, apple_url: "https://itunes.apple.com/us/podcast/the-changelog/id341623264")

      assert PodcastView.subscribe_on_overcast_url(p) ==
               "https://overcast.fm/itunes341623264/the-changelog"
    end
  end

  describe "subscribe_on_pocket_casts_url" do
    test "reformats the Apple URL as necessary" do
      p =
        build(:podcast, apple_url: "https://itunes.apple.com/us/podcast/the-changelog/id341623264")

      assert PodcastView.subscribe_on_pocket_casts_url(p) ==
               "https://pca.st/itunes/341623264"
    end
  end

  describe "subscribe_on_android_url" do
    test "reformats the feed URL as necessary" do
      p = build(:podcast, slug: "ohai")
      assert String.match?(PodcastView.subscribe_on_android_url(p), ~r/\/ohai\/feed\Z/)
    end
  end
end
