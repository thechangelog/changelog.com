defmodule ChangelogWeb.FeedViewTest do
  use ChangelogWeb.ConnCase, async: true

  alias ChangelogWeb.FeedView

  describe "custom_episode_title/2" do
    test "defaults to episode title when feed is empty" do
      episode = build(:episode, title: "Why testing is cool")
      title = FeedView.custom_episode_title(nil, episode)
      assert title == "Why testing is cool"
    end

    test "defaults to episode title when title_format is empty" do
      episode = build(:episode, title: "Why testing is cool")
      feed = build(:feed, title_format: "")
      title = FeedView.custom_episode_title(feed, episode)
      assert title == "Why testing is cool"
    end

    test "substitutes episode title and subtitle" do
      episode = build(:episode, title: "Why testing is cool", subtitle: "and so are you")
      feed = build(:feed, title_format: "{title} ({subtitle})")
      title = FeedView.custom_episode_title(feed, episode)
      assert title == "Why testing is cool (and so are you)"
    end

    test "substitutes podcast name and number" do
      podcast = build(:podcast, name: "The Changelog")
      episode = build(:episode, title: "Why testing is cool", podcast: podcast, slug: "123")
      feed = build(:feed, title_format: "{podcast} \#{number}: {title}")
      title = FeedView.custom_episode_title(feed, episode)
      assert title == "The Changelog #123: Why testing is cool"
    end

    test "excludes episode number when slug is not an integer" do
      episode = build(:episode, title: "Why testing is cool", slug: "bonus-test")
      feed = build(:feed, title_format: "{title} \#{number}:")
      title = FeedView.custom_episode_title(feed, episode)
      assert title == "Why testing is cool \#:"
    end

    test "excludes data from format when not available" do
      episode = build(:episode, title: "Why testing is cool", slug: nil, podcast: nil)
      feed = build(:feed, title_format: "{podcast} \#{number}: {title} ({subtitle})")
      title = FeedView.custom_episode_title(feed, episode)
      assert title == " #: Why testing is cool ()"
    end
  end

  describe "episode_title/2" do
    test "includes podcast in parentheses when master" do
      podcast = build(:podcast, name: "Master", slug: "master")

      episode =
        build(:episode,
          title: "Why testing is cool",
          slug: "bonus",
          podcast: %{name: "The Changelog", slug: "podcast"}
        )

      title = FeedView.episode_title(podcast, episode)
      assert title == "Why testing is cool (The Changelog)"
    end

    test "includes podcast and number in parentheses when master" do
      podcast = build(:podcast, name: "Master", slug: "master")

      episode =
        build(:episode,
          title: "Why testing is cool",
          slug: "12",
          podcast: %{name: "The Changelog", slug: "podcast"}
        )

      title = FeedView.episode_title(podcast, episode)
      assert title == "Why testing is cool (The Changelog #12)"
    end

    test "only includes episode title when not master" do
      podcast = build(:podcast, name: "Practial AI", slug: "practicalai")
      episode = build(:episode, title: "Why testing is cool", slug: "12", podcast: podcast)
      title = FeedView.episode_title(podcast, episode)
      assert title == "Why testing is cool"
    end
  end
end
