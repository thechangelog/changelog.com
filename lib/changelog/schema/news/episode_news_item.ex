defmodule Changelog.EpisodeNewsItem do
  use Changelog.Schema

  alias Changelog.{Episode, NewsItem, TypesenseSearch}
  alias ChangelogWeb.EpisodeView

  def insert(episode, logger), do: insert(episode, logger, false)

  def insert(episode, logger, feed_only) do
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
    |> NewsItem.insert_changeset()
    |> Repo.insert!()
  end

  def update(episode) do
    if item = Episode.get_news_item(episode) do
      item
      |> NewsItem.preload_topics()
      |> change(%{
        url: EpisodeView.episode_url(episode, :show),
        headline: episode.title,
        story: episode.summary,
        news_item_topics: episode_topics(episode)
      })
      |> Repo.update!()
      |> update_search()
    end
  end

  def delete(episode) do
    if item = Episode.get_news_item(episode) do
      Repo.delete!(item)
    end
  end

  defp episode_topics(episode) do
    episode
    |> Episode.preload_topics()
    |> Map.get(:episode_topics)
    |> Enum.map(fn t -> Map.take(t, [:topic_id, :position]) end)
  end

  defp update_search(item) do
    Task.start_link(fn -> TypesenseSearch.update_item(item) end)
    item
  end
end
