defmodule Changelog.HN.HNTest do
  use Changelog.SchemaCase

  import Mock

  alias Changelog.{HN, NewsItem}

  describe "submit/1" do
    test "is a no-op when news item is feed-only" do
      item = %NewsItem{feed_only: true}

      with_mock(HN.Client, submit: fn _, _ -> true end) do
        HN.submit(item)
        refute called(HN.Client.submit())
      end
    end

    test "calls Client.submit with title/url for regular news items" do
      item = build(:news_item, headline: "ohai", url: "https://test.com")

      with_mock(HN.Client, submit: fn _, _ -> true end) do
        HN.submit(item)
        assert called(HN.Client.submit("ohai", "https://test.com"))
      end
    end

    test "calls Client.submit with augmented title for episode news items" do
      episode = build(:episode, title: "gOOd One!")
      item = episode |> episode_news_item()

      with_mock(HN.Client, submit: fn _, _ -> true end) do
        HN.submit(item)
        assert called(HN.Client.submit("gOOd One! [audio]", item.url))
      end
    end
  end
end
