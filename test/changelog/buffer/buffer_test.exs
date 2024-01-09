defmodule Changelog.Buffer.BufferTest do
  use Changelog.SchemaCase

  import Mock

  alias Changelog.{Buffer, Episode, NewsItem}

  describe "profiles_for_topics/1" do
    test "returns @jsparty on matching topics" do
      topics = [%{slug: "css"}, %{slug: "nope"}]
      profiles = Buffer.profiles_for_topics(topics)
      assert profiles == ~w(58b47fd78d23761f5f19ca89)
    end

    test "returns @jsparty and @brainscience on matching topics" do
      topics = [%{slug: "javascript"}, %{slug: "brain-science"}]
      profiles = Buffer.profiles_for_topics(topics)
      assert profiles == ~w(58b47fd78d23761f5f19ca89 5d49c7410eb4bb4992040a42)
    end

    test "returns nothing when no match" do
      topics = [%{slug: "nope"}]
      profiles = Buffer.profiles_for_topics(topics)
      assert profiles == []
    end
  end

  describe "queue/1" do
    test "calls episode functions and Client.create when gotime audio news item" do
      episode = insert(:episode)
      item = %NewsItem{type: :audio, object_id: Episode.object_id(episode)}

      with_mocks([
        {Buffer.Content, [], [episode_text: fn _ -> "text" end]},
        {Buffer.Content, [], [episode_link: fn _ -> "url1" end]},
        {Buffer.Client, [], [create: fn _, _, _ -> true end]}
      ]) do
        Buffer.queue(item)
        assert called(Buffer.Client.create(:_, "text", link: "url1"))
      end
    end

    test "is a no-op when news item is feed-only" do
      item = %NewsItem{feed_only: true}

      with_mock(Buffer.Client, create: fn _, _, _ -> true end) do
        Buffer.queue(item)
        refute called(Buffer.Client.create())
      end
    end

    test "is a no-op when sent News episode" do
      news = insert(:podcast, slug: "news")
      episode = insert(:episode, podcast: news)
      item = %NewsItem{type: :audio, object_id: Episode.object_id(episode)}

      with_mocks([
        {Buffer.Content, [], [episode_text: fn _ -> "text" end]},
        {Buffer.Content, [], [episode_link: fn _ -> "url1" end]},
        {Buffer.Client, [], [create: fn _, _, _ -> true end]}
      ]) do
        Buffer.queue(item)
        assert called(Buffer.Client.create(nil, "text", link: "url1"))
      end
    end

    test "is a no-op when sent other audio news item" do
      item = %NewsItem{type: :audio}

      with_mock(Buffer.Client, create: fn _, _, _ -> true end) do
        Buffer.queue(item)
        refute called(Buffer.Client.create())
      end
    end

    test "calls post functions and Client.create when news item with post object" do
      insert(:published_post, slug: "this-is-one")
      item = %NewsItem{type: :post, object_id: "posts:this-is-one"}

      with_mocks([
        {Buffer.Content, [], [post_brief: fn _ -> "brief" end]},
        {Buffer.Content, [], [post_text: fn _ -> "text" end]},
        {Buffer.Content, [], [post_link: fn _ -> "url1" end]},
        {Buffer.Client, [], [create: fn _, _, _ -> true end]}
      ]) do
        Buffer.queue(item)
        assert called(Buffer.Client.create(:_, "text", link: "url1"))
      end
    end

    test "calls news_item functions and Client.create when sent a non-audio news item" do
      item = %NewsItem{type: :link}

      with_mocks([
        {Buffer.Content, [], [news_item_brief: fn _ -> "brief" end]},
        {Buffer.Content, [], [news_item_text: fn _ -> "text" end]},
        {Buffer.Content, [], [news_item_link: fn _ -> "url1" end]},
        {Buffer.Content, [], [news_item_image: fn _ -> "url2" end]},
        {Buffer.Client, [], [create: fn _, _, _ -> true end]}
      ]) do
        Buffer.queue(item)
        assert called(Buffer.Client.create(:_, "text", link: "url1", photo: "url2"))
      end
    end

    test "calls news_item functions and Client.create for each profile " do
      item = insert(:news_item)
      topic = insert(:topic, slug: "javascript")
      insert(:news_item_topic, news_item: item, topic: topic)

      with_mocks([
        {Buffer.Content, [], [news_item_brief: fn _ -> "brief" end]},
        {Buffer.Content, [], [news_item_text: fn _ -> "text" end]},
        {Buffer.Content, [], [news_item_link: fn _ -> "url1" end]},
        {Buffer.Content, [], [news_item_image: fn _ -> "url2" end]},
        {Buffer.Client, [], [create: fn _, _, _ -> true end]}
      ]) do
        Buffer.queue(item)
        assert called(Buffer.Client.create(:_, "text", link: "url1", photo: "url2"))
        assert called(Buffer.Client.create(:_, "brief", link: "url1", photo: "url2"))
      end
    end
  end
end
