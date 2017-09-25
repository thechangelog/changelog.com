defmodule Changelog.NewsQueueTest do
  use Changelog.DataCase

  alias Changelog.{NewsItem, NewsQueue}

  describe "append" do
    test "when queue is empty" do
      assert Repo.count(NewsQueue) == 0

      item = insert(:news_item)
      NewsQueue.append(item)
      entries = Repo.all(NewsQueue.ordered)

      assert length(entries) == 1
      assert Enum.map(entries, &(&1.item_id)) == [item.id]
    end

    test "when queue already has entries" do
      i1 = insert(:news_item)
      i2 = insert(:news_item)

      insert(:news_queue, item: i1, position: 1.0)
      insert(:news_queue, item: i2, position: 1.5)

      item = insert(:news_item)
      NewsQueue.append(item)
      entries = Repo.all(NewsQueue.ordered)

      assert length(entries) == 3
      assert Enum.map(entries, &(&1.item_id)) == [i1.id, i2.id, item.id]
    end
  end

  describe "move" do
    setup do
      i1 = insert(:news_item)
      i2 = insert(:news_item)
      i3 = insert(:news_item)

      insert(:news_queue, item: i1, position: 1.0)
      insert(:news_queue, item: i2, position: 1.5)
      insert(:news_queue, item: i3, position: 3.0)

      %{items: [i1, i2, i3]}
    end

    test "to negative index", %{items: [i1, i2, i3]} do
      NewsQueue.move(i3, -12)
      entries = Repo.all(NewsQueue.ordered)
      assert Enum.map(entries, &(&1.item_id)) == [i3.id, i1.id, i2.id]
    end

    test "to index 0", %{items: [i1, i2, i3]} do
      NewsQueue.move(i3, 0)
      entries = Repo.all(NewsQueue.ordered)
      assert Enum.map(entries, &(&1.item_id)) == [i3.id, i1.id, i2.id]
      NewsQueue.move(i2, 0)
      entries = Repo.all(NewsQueue.ordered)
      assert Enum.map(entries, &(&1.item_id)) == [i2.id, i3.id, i1.id]
    end

    test "to the middle of the pack", %{items: [i1, i2, i3]} do
      NewsQueue.move(i3, 1)
      entries = Repo.all(NewsQueue.ordered)
      assert Enum.map(entries, &(&1.item_id)) == [i1.id, i3.id, i2.id]
      NewsQueue.move(i1, 1)
      entries = Repo.all(NewsQueue.ordered)
      assert Enum.map(entries, &(&1.item_id)) == [i3.id, i1.id, i2.id]
      NewsQueue.move(i2, 1)
      entries = Repo.all(NewsQueue.ordered)
      assert Enum.map(entries, &(&1.item_id)) == [i3.id, i2.id, i1.id]
    end

    test "off the end", %{items: [i1, i2, i3]} do
      NewsQueue.move(i2, 12)
      entries = Repo.all(NewsQueue.ordered)
      assert Enum.map(entries, &(&1.item_id)) == [i1.id, i3.id, i2.id]
    end
  end

  describe "prepend" do
    test "when queue is empty" do
      assert Repo.count(NewsQueue) == 0

      item = insert(:news_item)
      NewsQueue.prepend(item)
      entries = Repo.all(NewsQueue.ordered)

      assert length(entries) == 1
      assert Enum.map(entries, &(&1.item_id)) == [item.id]
    end

    test "when queue already has entries" do
      i1 = insert(:news_item)
      i2 = insert(:news_item)

      insert(:news_queue, item: i1, position: 3.0)
      insert(:news_queue, item: i2, position: 15.0)

      item = insert(:news_item)
      NewsQueue.prepend(item)
      entries = Repo.all(NewsQueue.ordered)

      assert length(entries) == 3
      assert Enum.map(entries, &(&1.item_id)) == [item.id, i1.id, i2.id]
    end
  end

  describe "publish_next" do
    test "it is a no-op when queue is empty" do
      assert NewsQueue.publish_next() == true
    end

    test "it publishes the next news item, removing it from the queue" do
      assert Repo.count(NewsItem.published) == 0

      i1 = insert(:news_item)
      i2 = insert(:news_item)

      insert(:news_queue, item: i1, position: 1.0)
      insert(:news_queue, item: i2, position: 2.0)

      NewsQueue.publish_next()

      published = Repo.all(NewsItem.published)
      assert Enum.map(published, &(&1.id)) == [i1.id]
      assert Repo.count(NewsQueue) == 1

      NewsQueue.publish_next()

      published = NewsItem.published |> NewsItem.newest_first |> Repo.all
      assert Enum.map(published, &(&1.id)) == [i2.id, i1.id]
      assert Repo.count(NewsQueue) == 0
    end
  end
end
