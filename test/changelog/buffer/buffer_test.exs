defmodule Changelog.Buffer.BufferTest do
  use ExUnit.Case

  import Mock

  alias Changelog.{Buffer, NewsItem}

  describe "queue" do
    test "is a no-op when sent an audio news item" do
      item = %NewsItem{type: :audio}

      with_mock Buffer.Client, [create: fn(_, _, _) -> true end] do
        Buffer.queue(item)
        refute called(Buffer.Client.create())
      end
    end

    test "calls Client.create when sent a non-audio news item" do
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
