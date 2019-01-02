defmodule Changelog.Buffer.BufferTest do
  use ExUnit.Case

  import Mock

  alias Changelog.{Buffer, NewsItem}

  describe "queue" do
    test "calls episode functions and Client.create when gotime audio news item" do
      item = %NewsItem{type: :audio, object_id: "gotime:45"}

      with_mocks([
        {Buffer.Content, [], [episode_text: fn(_) -> "text" end]},
        {Buffer.Content, [], [episode_link: fn(_) -> "url1" end]},
        {Buffer.Client, [], [create: fn(_, _, _) -> true end]}
      ]) do
        Buffer.queue(item)
        assert called(Buffer.Client.create(:_, "text", [link: "url1"]))
      end
    end

    test "is a no-op when sent other audio news item" do
      item = %NewsItem{type: :audio}

      with_mock Buffer.Client, [create: fn(_, _, _) -> true end] do
        Buffer.queue(item)
        refute called(Buffer.Client.create())
      end
    end

    test "calls post functions and Client.create when news item with post object" do
      item = %NewsItem{type: :link, object_id: "posts:this-is-one"}

      with_mocks([
        {Buffer.Content, [], [post_text: fn(_) -> "text" end]},
        {Buffer.Content, [], [post_link: fn(_) -> "url1" end]},
        {Buffer.Client, [], [create: fn(_, _, _) -> true end]}
      ]) do
        Buffer.queue(item)
        assert called(Buffer.Client.create(:_, "text", [link: "url1"]))
      end
    end

    test "calls news_item functions and Client.create when sent a non-audio news item" do
      item = %NewsItem{type: :link}

      with_mocks([
        {Buffer.Content, [], [news_item_text: fn(_) -> "text" end]},
        {Buffer.Content, [], [news_item_link: fn(_) -> "url1" end]},
        {Buffer.Content, [], [news_item_image: fn(_) -> "url2" end]},
        {Buffer.Client, [], [create: fn(_, _, _) -> true end]}
      ]) do
        Buffer.queue(item)
        assert called(Buffer.Client.create(:_, "text", [link: "url1", photo: "url2"]))
      end
    end
  end
end
