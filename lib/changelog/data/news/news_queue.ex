defmodule Changelog.NewsQueue do
  use Changelog.Data

  require Logger

  alias Changelog.{Buffer, NewsItem, NewsQueue, Notifier, Search}

  schema "news_queue" do
    field :position, :float
    belongs_to :item, NewsItem
  end

  def queued(query \\ NewsQueue) do
    from(q in query,
      left_join: i in assoc(q, :item),
      where: is_nil(i.published_at),
      order_by: q.position)
  end

  def scheduled(query \\ NewsQueue) do
    from(q in query,
      left_join: i in assoc(q, :item),
      where: not(is_nil(i.published_at)),
      order_by: i.published_at)
  end

  def past(query), do: from([_q, i] in query, where: i.published_at <= ^Timex.now)

  def append(item) do
    entry = change(%NewsQueue{}, %{item_id: item.id})

    entries = Repo.all(NewsQueue.queued)

    entry = if length(entries) > 0 do
      last_position = List.last(entries).position
      change(entry, %{position: last_position + 1.0})
    else
      change(entry, %{position: 1.0})
    end

    Repo.insert(entry)
    NewsItem.queue!(item)
  end

  def move(item = %NewsItem{}, to_index) do
    entry = Repo.get_by(NewsQueue, item_id: item.id)
    move(entry, to_index)
  end

  def move(entry = %NewsQueue{}, to_index) do
    entries = Repo.all(NewsQueue.queued)
    current_index = Enum.find_index(entries, &(&1 == entry))

    entry = cond do
      to_index <= 0 -> # move to top
        first = List.first(entries)
        change(entry, %{position: first.position / 2})
      to_index >= (length(entries) - 1) -> # move to bottom
        last = List.last(entries)
        change(entry, %{position: last.position + 1})
      to_index < current_index -> # move up
        pre = Enum.at(entries, to_index - 1)
        post = Enum.at(entries, to_index)
        change(entry, %{position: (pre.position + post.position) / 2})
      to_index > current_index -> # move down
        pre = Enum.at(entries, to_index)
        post = Enum.at(entries, to_index + 1)
        change(entry, %{position: (pre.position + post.position) / 2})
      true -> change(entry, %{}) # no move-y
    end

    Repo.update(entry)
  end

  def preload_all(query = %Ecto.Query{}), do: Ecto.Query.preload(query, [item: [:author, :logger, :topics]])
  def preload_all(entry), do: Repo.preload(entry, [item: [:author, :logger, :topics]])

  def prepend(item) do
    entry = change(%NewsQueue{}, %{item_id: item.id})

    entries = NewsQueue.queued |> Repo.all

    entry = if length(entries) > 0 do
      first_position = List.first(entries).position
      change(entry, %{position: first_position / 2})
    else
      change(entry, %{position: 1.0})
    end

    Repo.insert(entry)
    NewsItem.queue!(item)
  end

  def publish_next do
    NewsQueue.queued()
    |> NewsQueue.limit(1)
    |> Repo.one()
    |> publish()
  end

  def publish_scheduled do
    NewsQueue.scheduled()
    |> NewsQueue.past()
    |> NewsQueue.limit(1)
    |> Repo.one()
    |> publish()
  end

  def publish do
    publish_scheduled() || publish_next_maybe(10 , 60)
  end
  def publish(item = %NewsItem{}) do
    case Repo.get_by(NewsQueue, item_id: item.id) do
      entry = %NewsQueue{} -> publish(entry)
      nil -> publish_item(item)
    end
  end
  def publish(entry = %NewsQueue{}) do
    entry = Repo.preload(entry, :item)
    publish_item(entry.item)
    Repo.delete!(entry)
    true
  end
  def publish(nil) do
    Logger.info("News: Published bupkis")
    false
  end

  defp publish_item(item = %NewsItem{}) do
    item = NewsItem.publish!(item)
    Task.start_link(fn -> Search.save_item(item) end)
    Task.start_link(fn -> Buffer.queue(item) end)
    Task.start_link(fn -> Notifier.notify(item) end)
    Logger.info("News: Published ##{item.id}")
    true
  end

  defp publish_next_maybe(per_day, interval) do
    if one_chance_in(5) && nothing_recent(interval) && no_max(per_day) do
      publish_next()
    end
  end

  defp one_chance_in(n), do: Enum.random(1..n) == 1

  defp nothing_recent(interval) do
    Timex.now()
    |> Timex.shift(minutes: -interval)
    |> NewsItem.published_since()
    |> Repo.count()
    |> Kernel.==(0)
  end

  defp no_max(per_day) do
    Timex.now()
    |> Timex.shift(days: -1)
    |> NewsItem.published_since()
    |> Repo.count()
    |> Kernel.<(per_day)
  end
end
