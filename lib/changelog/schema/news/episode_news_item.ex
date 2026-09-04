defmodule Changelog.EpisodeNewsItem do
  use Changelog.Schema

  alias Changelog.{Episode, NewsItem, TypesenseSearch}
  alias ChangelogWeb.EpisodeView

  def insert(episode, logger), do: insert(episode, logger, false)

  def insert(episode, logger, feed_only) do
    result = insert_with_result(episode, logger, feed_only)

    if Repo.in_transaction?() do
      result.item
    else
      refresh_search(result)
    end
  end

  def insert_with_result(episode, logger, feed_only) do
    Repo.transaction(fn ->
      episode
      |> lock_episode()
      |> insert_locked(logger, feed_only)
    end)
    |> unwrap_transaction!()
  end

  def insert_published_feed_only_once(episode, logger) do
    Repo.transaction(fn ->
      episode = lock_episode(episode)

      case canonical_item(episode) do
        nil -> {:created, episode |> create_item(logger, true) |> NewsItem.publish!()}
        item -> {:existing, item}
      end
    end)
    |> unwrap_transaction!()
  end

  defp insert_locked(episode, logger, feed_only) do
    case canonical_item(episode) do
      nil ->
        result(create_item(episode, logger, feed_only), false)

      item ->
        item
        |> reconcile_changeset(episode, %{
          feed_only: reconciled_feed_only(item, feed_only),
          logger_id: logger.id
        })
        |> Repo.update!()
        |> result(true)
    end
  end

  def update(episode) do
    if item = canonical_item(episode) do
      item
      |> reconcile_changeset(episode, %{})
      |> Repo.update!()
      |> update_search()
    end
  end

  def delete(episode) do
    if item = canonical_item(episode) do
      Repo.delete!(item)
    end
  end

  defp lock_episode(episode) do
    from(e in Episode,
      where: e.id == ^episode.id,
      lock: "FOR UPDATE"
    )
    |> Repo.one!()
  end

  defp canonical_item(episode) do
    from(item in NewsItem.with_episode(episode),
      order_by: [asc: item.inserted_at, asc: item.id],
      limit: 1
    )
    |> Repo.one()
  end

  defp create_item(episode, logger, feed_only) do
    episode
    |> build_item(logger, feed_only)
    |> NewsItem.insert_changeset()
    |> Repo.insert!()
  end

  defp build_item(episode, logger, feed_only) do
    %NewsItem{
      type: :audio,
      feed_only: feed_only,
      object_id: Episode.object_id(episode),
      url: EpisodeView.episode_url(episode, :show),
      headline: episode.title,
      story: episode.summary,
      published_at: episode.published_at,
      logger_id: logger.id,
      news_item_topics: episode_topics(episode)
    }
  end

  defp reconcile_changeset(item, episode, attrs) do
    item
    |> NewsItem.preload_topics()
    |> change(
      Map.merge(
        reconcile_attrs(item, episode),
        attrs
      )
    )
  end

  defp reconcile_attrs(item, episode) do
    %{
      url: EpisodeView.episode_url(episode, :show),
      headline: episode.title,
      story: episode.summary,
      news_item_topics: episode_topics(episode)
    }
    |> Map.merge(reconciled_published_at(item, episode))
  end

  defp reconciled_published_at(%NewsItem{status: :published}, episode) do
    %{published_at: episode.published_at}
  end

  defp reconciled_published_at(_item, _episode), do: %{}

  defp reconciled_feed_only(_item, false), do: false
  defp reconciled_feed_only(item, true), do: item.feed_only

  defp episode_topics(episode) do
    episode
    |> Episode.preload_topics()
    |> Map.get(:episode_topics)
    |> Enum.map(fn t -> Map.take(t, [:topic_id, :position]) end)
  end

  defp update_search(item) do
    if Application.get_env(:changelog, :sync_episode_news_item_search, false) do
      TypesenseSearch.update_item(item)
    else
      Task.start(fn -> TypesenseSearch.update_item(item) end)
    end

    item
  end

  def refresh_search(%{item: item, update_search?: true}), do: update_search(item)
  def refresh_search(%{item: item, update_search?: false}), do: item

  defp result(item, update_search?), do: %{item: item, update_search?: update_search?}

  defp unwrap_transaction!({:ok, result}), do: result
end
