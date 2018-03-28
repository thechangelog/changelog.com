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
      assert Content.episode_text(item) =~ "#security, @OfficialiOS"
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

    test "returns item url when story is less than 20 words" do
      item = build(:news_item, story: "This is too short")
      assert Content.news_item_link(item) == item.url
    end

    test "returns news item permalink when story is 20 words or more" do
      item = insert(:news_item, story: "one two three four five six seven eight nine ten eleven twelve thirteen fourteen fifteen sixteen seventeen eighteen nineteen twenty")
      assert Content.news_item_link(item) == Router.Helpers.news_item_url(Endpoint, :show, NewsItemView.hashid(item))
    end
  end

  describe "news_item_text" do
    test "defaults to empty string" do
      assert Content.news_item_text(nil) == ""
    end

    test "includes topic tags and twitter handles" do
      item = insert(:news_item, headline: "News of iOS 9 doing Machine Learning things.")
      t1 = insert(:topic, name: "iOS", slug: "ios", twitter_handle: "OfficialiOS")
      t2 = insert(:topic, name: "Machine Learning", slug: "machine-learning")
      t3 = insert(:topic, name: "Security", slug: "security")
      insert(:news_item_topic, news_item: item, topic: t1)
      insert(:news_item_topic, news_item: item, topic: t2)
      insert(:news_item_topic, news_item: item, topic: t3)
      assert Content.news_item_text(item) =~ "@OfficialiOS, #machinelearning, #security"
    end

    test "includes 'via' when news source has twitter handle" do
      source = insert(:news_source, twitter_handle: "wired")
      item = insert(:news_item, source: source)
      t1 = insert(:topic, name: "iOS", slug: "ios")
      insert(:news_item_topic, news_item: item, topic: t1)
      assert Content.news_item_text(item) =~ "via @wired"
    end

    test "excludes 'via' when news source has no twitter handle" do
      source = insert(:news_source)
      item = insert(:news_item, source: source)
      refute Content.news_item_text(item) =~ " via "
    end

    test "includes 'by' when item has author and handle" do
      author = insert(:person, twitter_handle: "BigDaddy")
      item = insert(:news_item, author: author)
      assert Content.news_item_text(item) =~ "by @BigDaddy"
    end

    test "excludes 'by' when item author has no twitter handle" do
      author = insert(:person)
      item = insert(:news_item, author: author)
      refute Content.news_item_text(item) =~ " by "
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

  describe "post_text" do
    # test "calls news_item_text" do
    #   item = build(:news_item)
    #   with_mock(Content, [news_item_text: fn() -> "text" end]) do
    #     Content.post_text(item)
    #     assert called(Content.news_item_text(item))
    #   end
    # end
  end
end
