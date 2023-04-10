defmodule ChangelogWeb.FeedViewTest do
  use ChangelogWeb.ConnCase, async: true

  alias ChangelogWeb.FeedView

  describe "episode_title/2" do
    test "includes podcast in parentheses when master" do
      podcast = %{name: "Master", slug: "master"}
      episode = %{title: "Why testing is cool", slug: "bonus", podcast: %{name: "The Changelog", slug: "podcast"}}
      title = FeedView.episode_title(podcast, episode)
      assert title == "Why testing is cool (The Changelog)"
    end

    test "includes podcast and number in parentheses when master" do
      podcast = %{name: "Master", slug: "master"}
      episode = %{title: "Why testing is cool", slug: "12", podcast: %{name: "The Changelog", slug: "podcast"}}
      title = FeedView.episode_title(podcast, episode)
      assert title == "Why testing is cool (The Changelog #12)"
    end

    test "only includes episode title when not master" do
      podcast = %{name: "Practial AI", slug: "practicalai"}
      episode = %{title: "Why testing is cool", slug: "12", podcast: podcast}
      title = FeedView.episode_title(podcast, episode)
      assert title == "Why testing is cool"
    end
  end
end
