defmodule Changelog.ObanWorkers.FeedUpdater do
  require Logger
  @moduledoc """
  This module defines the Oban worker for updating feed files
  """
  use Oban.Worker, queue: :feeds

  alias Changelog.{Episode, NewsItem, Podcast}

  @impl Oban.Worker
  def perform(%Job{args: %{"slug" => slug}}) do
    ChangelogWeb.Feeds.refresh(slug)
  end

  def queue(item = %NewsItem{}) do
    item = NewsItem.load_object(item)
    queue(item.object)
  end

  def queue(episode = %Episode{}) do
    episode = Episode.preload_podcast(episode)
    queue(episode.podcast)
  end

  def queue(%Podcast{slug: "podcast", is_meta: false}) do
    queue_slugs(~w(interviews podcast master))
  end

  def queue(%Podcast{slug: "podcast", is_meta: true}) do
    queue_slugs(~w(podcast master))
  end

  def queue(%Podcast{slug: "friends"}) do
    queue_slugs(~w(friends podcast master))
  end

  def queue(%Podcast{slug: "news"}) do
    queue_slugs(~w(news podcast master))
  end

  def queue(%Podcast{slug: slug}) do
    queue_slugs(~w(#{slug} master))
  end

  def queue(_), do: nil

  defp queue_slugs(slugs) when is_list(slugs) do
    for slug <- slugs do
      %{"slug" => slug} |> new() |> Oban.insert()
    end
  end
end
