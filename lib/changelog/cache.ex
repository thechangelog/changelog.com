defmodule Changelog.Cache do
  @moduledoc """
  A small wrapper around ConCache to simplify interface
  """
  require Logger

  alias Changelog.{Episode, NewsItem, Podcast, Post, Repo}

  def cache_name, do: :app_cache

  def delete(nil), do: :ok

  def delete(episode = %Episode{}) do
    episode = Episode.preload_podcast(episode)
    delete_prefix("/#{episode.podcast.slug}/#{episode.slug}")

    if Podcast.is_a_changelog_pod(episode.podcast) do
      delete_prefix("/podcast")
    end

    if Podcast.is_changelog(episode.podcast) do
      delete_prefix("/interviews")
    end

    if Episode.is_public(episode) do
      delete_prefix(episode.podcast.slug)
      delete_prefix("/master")
      delete_prefix("/plusplus")
    end
  end

  def delete(item = %NewsItem{}) do
    item = NewsItem.load_object(item)
    delete_prefix("/news/#{NewsItem.slug(item)}")
    delete(item.object)
  end

  def delete(podcast = %Podcast{}) do
    delete_prefix("podcasts")
    delete_prefix("/#{podcast.slug}")
  end

  def delete(post = %Post{}) do
    delete("/posts/#{post.slug}")
  end

  def delete(key) do
    Logger.info("Cache: Deleting #{key}")
    ConCache.delete(cache_name(), key)
  end

  def delete_all do
    Enum.each(keys(), fn key -> delete(key) end)
  end

  def delete_prefix(prefix) do
    keys()
    |> Enum.filter(fn key -> key =~ prefix end)
    |> Enum.each(fn key -> delete(key) end)
  end

  def get(key), do: ConCache.get(cache_name(), key)

  def get_or_store(key, function) do
    ConCache.get_or_store(cache_name(), key, fn ->
      value = apply(function, [])
      %ConCache.Item{value: value, ttl: :infinity}
    end)
  end

  def get_or_store(key, ttl, function) do
    ConCache.get_or_store(cache_name(), key, fn ->
      value = apply(function, [])
      %ConCache.Item{value: value, ttl: ttl}
    end)
  end

  def put(key, item), do: ConCache.put(cache_name(), key, item)

  def put(key, item, ttl) do
    item = %ConCache.Item{value: item, ttl: ttl}
    put(key, item)
  end

  def keys do
    cache_name()
    |> ConCache.ets()
    |> :ets.tab2list()
    |> Enum.map(&elem(&1, 0))
  end

  def active_podcasts do
    get_or_store("podcasts_active", :infinity, fn ->
      Enum.filter(podcasts(), &Podcast.is_active/1)
    end)
  end

  def podcasts do
    get_or_store("podcasts_all", :infinity, fn ->
      Podcast.public()
      |> Podcast.by_position()
      |> Podcast.preload_active_hosts()
      |> Podcast.preload_retired_hosts()
      |> Repo.all()
    end)
  end

  def vanity_domains do
    get_or_store("vanity", :infinity, fn ->
      Podcast.with_vanity_domain() |> Repo.all()
    end)
  end
end
