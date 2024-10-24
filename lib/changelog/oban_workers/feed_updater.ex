defmodule Changelog.ObanWorkers.FeedUpdater do
  require Logger

  @moduledoc """
  This module defines the Oban worker for updating feed files
  """
  use Oban.Worker, queue: :feeds

  alias Changelog.{Episode, Feed, NewsItem, Podcast, Post, Repo}

  @impl Oban.Worker
  def perform(%Job{args: %{"slug" => slug}}) do
    ChangelogWeb.Feeds.refresh(slug)

    :ok
  end

  def perform(%Job{args: %{"id" => id}}) do
    if feed = Repo.get(Feed, id) do
      ChangelogWeb.Feeds.refresh(feed)
    end

    :ok
  end

  def queue(episode = %Episode{}) do
    episode = Episode.preload_podcast(episode)
    queue(episode.podcast)
  end

  def queue(feed = %Feed{}) do
    %{"id" => feed.id} |> new() |> Oban.insert()
  end

  def queue(item = %NewsItem{}) do
    item = NewsItem.load_object(item)
    queue(item.object)
  end

  def queue(%Podcast{slug: "podcast", is_meta: true}) do
    queue_slugs(~w(podcast master feed plusplus))
  end

  def queue(%Podcast{id: id, slug: "podcast", is_meta: false}) do
    queue_slugs(~w(interviews podcast master feed plusplus))
    queue_feeds(id)
  end

  def queue(%Podcast{id: id, slug: "friends"}) do
    queue_slugs(~w(friends podcast master feed plusplus))
    queue_feeds(id)
  end

  def queue(%Podcast{id: id, slug: "news"}) do
    queue_slugs(~w(news podcast master feed plusplus))
    queue_feeds(id)
  end

  def queue(%Podcast{id: id, slug: slug}) do
    queue_slugs(~w(#{slug} master feed plusplus))
    queue_feeds(id)
  end

  def queue(%Post{}) do
    queue_slugs(~w(posts feed))
  end

  def queue(_), do: nil

  defp queue_slugs(slugs) when is_list(slugs) do
    for slug <- slugs do
      %{"slug" => slug} |> new() |> Oban.insert()
    end
  end

  defp queue_feeds(id) do
    feeds = id |> Feed.with_podcast_id() |> Repo.all()

    for feed <- feeds do
      queue(feed)
    end
  end
end
