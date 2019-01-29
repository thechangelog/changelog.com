defmodule Changelog.NewsQueueTest do
  use Changelog.DataCase

  import Mock

  alias Changelog.{Buffer, NewsItem, NewsQueue, Notifier}

  describe "append" do
    test "when queue is empty" do
      assert Repo.count(NewsQueue) == 0

      item = insert(:news_item)
      NewsQueue.append(item)
      entries = Repo.all(NewsQueue.queued)

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
      entries = Repo.all(NewsQueue.queued)

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
      entries = Repo.all(NewsQueue.queued)
      assert Enum.map(entries, &(&1.item_id)) == [i3.id, i1.id, i2.id]
    end

    test "to index 0", %{items: [i1, i2, i3]} do
      NewsQueue.move(i3, 0)
      entries = Repo.all(NewsQueue.queued)
      assert Enum.map(entries, &(&1.item_id)) == [i3.id, i1.id, i2.id]
      NewsQueue.move(i2, 0)
      entries = Repo.all(NewsQueue.queued)
      assert Enum.map(entries, &(&1.item_id)) == [i2.id, i3.id, i1.id]
    end

    test "to the middle of the pack", %{items: [i1, i2, i3]} do
      NewsQueue.move(i3, 1)
      entries = Repo.all(NewsQueue.queued)
      assert Enum.map(entries, &(&1.item_id)) == [i1.id, i3.id, i2.id]
      NewsQueue.move(i1, 1)
      entries = Repo.all(NewsQueue.queued)
      assert Enum.map(entries, &(&1.item_id)) == [i3.id, i1.id, i2.id]
      NewsQueue.move(i2, 1)
      entries = Repo.all(NewsQueue.queued)
      assert Enum.map(entries, &(&1.item_id)) == [i3.id, i2.id, i1.id]
    end

    test "off the end", %{items: [i1, i2, i3]} do
      NewsQueue.move(i2, 12)
      entries = Repo.all(NewsQueue.queued)
      assert Enum.map(entries, &(&1.item_id)) == [i1.id, i3.id, i2.id]
    end
  end

  describe "prepend" do
    test "when queue is empty" do
      assert Repo.count(NewsQueue) == 0

      item = insert(:news_item)
      NewsQueue.prepend(item)
      entries = Repo.all(NewsQueue.queued)

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
      entries = Repo.all(NewsQueue.queued)

      assert length(entries) == 3
      assert Enum.map(entries, &(&1.item_id)) == [item.id, i1.id, i2.id]
    end
  end

  describe "publish_next" do
    test "it is a no-op when queue is empty" do
      assert NewsQueue.publish_next() == false
    end

    test "it publishes the next news item, removing it from the queue" do
      assert Repo.count(NewsItem.published) == 0

      i1 = insert(:news_item)
      i2 = insert(:news_item)

      insert(:news_queue, item: i1, position: 1.0)
      insert(:news_queue, item: i2, position: 2.0)

      with_mocks([
        {Buffer, [], [queue: fn(_) -> true end]},
        {Algolia, [], [save_object: fn(_, _, _) -> true end]}
      ]) do
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

  describe "publish_scheduled" do
    test "it is a no-op when scheduled is empty" do
      assert NewsQueue.publish_scheduled() == false
    end

    test "it publishes the scheduled item, removing it from the queue" do
      assert Repo.count(NewsItem.published) == 0

      i1 = insert(:news_item, published_at: hours_ago(1))
      i2 = insert(:news_item)

      insert(:news_queue, item: i1, position: 1.0)
      insert(:news_queue, item: i2, position: 2.0)

      with_mocks([
        {Buffer, [], [queue: fn(_) -> true end]},
        {Algolia, [], [save_object: fn(_, _, _) -> true end]}
      ]) do
        NewsQueue.publish_scheduled()

        published = Repo.all(NewsItem.published)
        assert Enum.map(published, &(&1.id)) == [i1.id]
        assert Repo.count(NewsQueue) == 1

        NewsQueue.publish_scheduled()

        published = NewsItem.published |> NewsItem.newest_first |> Repo.all
        assert Enum.map(published, &(&1.id)) == [i1.id]
        assert Repo.count(NewsQueue) == 1
      end
    end
  end

  describe "publish" do
    test "it publishes the given item and buffers it even if it's not in the queue" do
      item = insert(:news_item)

      with_mocks([
        {Buffer, [], [queue: fn(_) -> true end]},
        {Notifier, [], [notify: fn(_) -> true end]},
        {Algolia, [], [save_object: fn(_, _, _) -> true end]}
      ]) do
        NewsQueue.publish(item)
        assert Repo.count(NewsItem.published) == 1
        assert called(Buffer.queue(:_))
        assert called(Notifier.notify(:_))
        assert called(Algolia.save_object(:_, :_, :_))
      end
    end

    test "it publishes the given item, removing it from the queue" do
      assert Repo.count(NewsItem.published) == 0

      i1 = insert(:news_item)
      i2 = insert(:news_item)
      i3 = insert(:news_item)

      insert(:news_queue, item: i1, position: 1.0)
      insert(:news_queue, item: i2, position: 2.0)
      insert(:news_queue, item: i3, position: 3.0)

      with_mocks([
        {Buffer, [], [queue: fn(_) -> true end]},
        {Algolia, [], [save_object: fn(_, _, _) -> true end]}
      ]) do
        NewsQueue.publish(i2)
        assert called(Buffer.queue(:_))
        assert called(Algolia.save_object(:_, :_, :_))
        published = Repo.all(NewsItem.published)
        assert Enum.map(published, &(&1.id)) == [i2.id]
        assert Repo.count(NewsQueue) == 2
      end

    end
  end

  describe "queued vs scheduled" do
    test "queued excludes items with published_at set" do
      i1 = insert(:news_item)
      i2 = insert(:news_item, published_at: hours_from_now(1))
      i3 = insert(:news_item)

      insert(:news_queue, item: i1, position: 1.0)
      insert(:news_queue, item: i2, position: 1.5)
      insert(:news_queue, item: i3, position: 2.0)

      entries = Repo.all(NewsQueue.queued)

      assert length(entries) == 2
      assert Enum.map(entries, &(&1.item_id)) == [i1.id, i3.id]
    end

    test "scheduled excludes items sans published_at and orders by it" do
      i1 = insert(:news_item)
      i2 = insert(:news_item, published_at: hours_from_now(2))
      i3 = insert(:news_item, published_at: hours_from_now(1))

      insert(:news_queue, item: i1, position: 1.0)
      insert(:news_queue, item: i2, position: 1.5)
      insert(:news_queue, item: i3, position: 2.0)

      entries = Repo.all(NewsQueue.scheduled)

      assert length(entries) == 2
      assert Enum.map(entries, &(&1.item_id)) == [i3.id, i2.id]
    end
  end
end
