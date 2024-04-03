defmodule ChangelogWeb.FeedViewTest do
  use ChangelogWeb.ConnCase, async: true

  alias ChangelogWeb.FeedView

  describe "custom_episode_title/2" do
    test "defaults to episode title when feed is empty" do
      episode = %{title: "Why testing is cool"}
      title = FeedView.custom_episode_title(nil, episode)
      assert title == "Why testing is cool"
    end

    test "defaults to episode title when title_format is empty" do
      episode = %{title: "Why testing is cool"}
      feed = %{title_format: ""}
      title = FeedView.custom_episode_title(feed, episode)
      assert title == "Why testing is cool"
    end

    test "substitutes episode title and subtitle" do
      episode = %{title: "Why testing is cool", subtitle: "and so are you"}
      feed = %{title_format: "{title} ({subtitle})"}
      title = FeedView.custom_episode_title(feed, episode)
      assert title == "Why testing is cool (and so are you)"
    end

    test "substitutes podcast name and number" do
      podcast = %{name: "The Changelog"}
      episode = %{title: "Why testing is cool", podcast: podcast, slug: "123"}
      feed = %{title_format: "{podcast} \#{number}: {title}"}
      title = FeedView.custom_episode_title(feed, episode)
      assert title == "The Changelog #123: Why testing is cool"
    end

    test "excludes episode number when slug is not an integer" do
      episode = %{title: "Why testing is cool", slug: "bonus-test"}
      feed = %{title_format: "{title} \#{number}:"}
      title = FeedView.custom_episode_title(feed, episode)
      assert title == "Why testing is cool \#:"
    end

    test "excludes data from format when not available" do
      episode = %{title: "Why testing is cool"}
      feed = %{title_format: "{podcast} \#{number}: {title} ({subtitle})"}
      title = FeedView.custom_episode_title(feed, episode)
      assert title == " #: Why testing is cool ()"
    end
  end

  describe "episode_title/2" do
    test "includes podcast in parentheses when master" do
      podcast = %{name: "Master", slug: "master"}

      episode = %{
        title: "Why testing is cool",
        slug: "bonus",
        podcast: %{name: "The Changelog", slug: "podcast"}
      }

      title = FeedView.episode_title(podcast, episode)
      assert title == "Why testing is cool (The Changelog)"
    end

    test "includes podcast and number in parentheses when master" do
      podcast = %{name: "Master", slug: "master"}

      episode = %{
        title: "Why testing is cool",
        slug: "12",
        podcast: %{name: "The Changelog", slug: "podcast"}
      }

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
