defmodule Changelog.Buffer.ContentTest do
  use Changelog.DataCase

  import Mock

  alias Changelog.Buffer.Content
  alias ChangelogWeb.{Endpoint, NewsItemView, Router}

  describe "episode_link" do
    test "defaults to nil" do
      assert is_nil(Content.episode_link(nil))
    end

    test "returns the item's url" do
      item = build(:news_item)
      assert Content.episode_link(item) == item.url
    end
  end

  describe "episode_text" do
    test "uses episode title" do
      ep1 = insert(:published_episode, title: "The Best", subtitle: "Evar!")
      item1 = ep1 |> episode_news_item() |> insert
      assert Content.episode_text(item1) =~ "The Best"
      refute Content.episode_text(item1) =~ "Evar!"
    end

    test "includes participant twitter handles and falls back to names" do
      g1 = insert(:person, twitter_handle: "janedoe")
      g2 = insert(:person, name: "John Doe")
      h1 = insert(:person, twitter_handle: "v_cool")
      ep = insert(:published_episode)
      insert(:episode_guest, episode: ep, person: g1, position: 1)
      insert(:episode_guest, episode: ep, person: g2, position: 2)
      insert(:episode_host, episode: ep, person: h1)
      item = ep |> episode_news_item() |> insert
      assert Content.episode_text(item) =~ "@janedoe, John Doe, @v_cool"
    end

    test "includes topic tags and twitter handles" do
      ep = insert(:published_episode)
      item = ep |> episode_news_item() |> insert
      t1 = insert(:topic, name: "Security", slug: "security")
      t2 = insert(:topic, name: "iOS", slug: "ios", twitter_handle: "OfficialiOS")
      insert(:news_item_topic, news_item: item, topic: t1)
      insert(:news_item_topic, news_item: item, topic: t2)
      assert Content.episode_text(item) =~ "#security @OfficialiOS"
    end
  end

  describe "news_item_image" do
    test "defaults to nil" do
      assert is_nil(Content.news_item_image(nil))
    end

    test "returns nil when item has no image" do
      assert is_nil(Content.news_item_image(%{image: nil}))
    end

    test "calls NewsItemView.image_url when item has image" do
      item = %{image: "yes"}
      with_mock(NewsItemView, [image_url: fn(_, _) -> "url" end]) do
        assert Content.news_item_image(item) == "url"
        assert called(NewsItemView.image_url(item, :original))
      end
    end
  end

  describe "news_item_link" do
    test "defaults to nil" do
      assert is_nil(Content.news_item_link(nil))
    end

    test "returns news item permalink" do
      item = insert(:news_item, story: "ohai here is a story")
      assert Content.news_item_link(item) == Router.Helpers.news_item_url(Endpoint, :show, NewsItemView.hashid(item))
    end
  end

  describe "news_item_text" do
    test "defaults to empty string" do
      assert Content.news_item_text(nil) == ""
    end

    test "uses verbose syntax with 0 or more topics" do
      item = insert(:news_item, headline: "News of iOS 9 doing Machine Learning things.")
      t1 = insert(:topic, name: "iOS", slug: "ios", twitter_handle: "OfficialiOS")
      t2 = insert(:topic, name: "Machine Learning", slug: "machine-learning")
      t3 = insert(:topic, name: "Security", slug: "security")
      insert(:news_item_topic, news_item: item, topic: t1)
      insert(:news_item_topic, news_item: item, topic: t2)
      insert(:news_item_topic, news_item: item, topic: t3)
      assert Content.news_item_text(item) =~ "@OfficialiOS #machinelearning #security"
    end

    test "uses verbose syntax with two topics, includes 'by' with author name" do
      author = insert(:person, twitter_handle: "ohai")
      item = insert(:news_item, author: author)
      t1 = insert(:topic, name: "iOS", slug: "ios", twitter_handle: "OfficialiOS")
      t2 = insert(:topic, name: "Machine Learning", slug: "machine-learning")
      insert(:news_item_topic, news_item: item, topic: t1)
      insert(:news_item_topic, news_item: item, topic: t2)
      text = Content.news_item_text(item)
      assert text =~ " by @ohai"
      assert text =~ "@OfficialiOS #machinelearning"
    end

    test "uses terse syntax with no topics, includes 'by' with author handle" do
      author = insert(:person, twitter_handle: "BigDaddy")
      item = insert(:news_item, author: author)
      assert Content.news_item_text(item) =~ "by @BigDaddy"
    end

    test "uses terse syntax with no topics, it includes author alone if source has no handle" do
      author = insert(:person, twitter_handle: "BigDaddy")
      source = insert(:news_source)
      item = insert(:news_item, author: author, source: source)
      text = Content.news_item_text(item)
      assert text =~ " by @BigDaddy"
      refute text =~ "via @wired"
    end

    test "it excludes source if there is no author" do
      source = insert(:news_source, twitter_handle: "wired")
      item = insert(:news_item, source: source)
      refute Content.news_item_text(item) =~ "via @wired"
    end
  end

  describe "post_link" do
    test "defaults to nil" do
      assert is_nil(Content.post_link(nil))
    end

    test "returns the item's url" do
      item = build(:news_item)
      assert Content.post_link(item) == item.url
    end
  end
end
