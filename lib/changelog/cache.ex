defmodule Changelog.Cache do
  @moduledoc """
  A small wrapper around ConCache to simplify interface
  """
  require Logger

  alias Changelog.{Episode, Podcast, Post, Repo}

  def cache_name, do: :app_cache

  def delete(nil), do: :ok
  def delete(episode = %Episode{}) do
    episode = Episode.preload_podcast(episode)
    delete_prefix("/#{episode.podcast.slug}/#{episode.slug}")
  end
  def delete(_podcast = %Podcast{}) do
    delete("podcasts")
  end
  def delete(post = %Post{}) do
    delete("/posts/#{post.slug}")
  end
  def delete(key) do
    Logger.info("Cache: Deleting #{key}")
    ConCache.delete(cache_name(), key)
  end

  def delete_all do
    Enum.each(keys(), fn(key) -> delete(key) end)
  end

  def delete_prefix(prefix) do
    keys()
    |> Enum.filter(fn(key) -> key =~ prefix end)
    |> Enum.each(fn(key) -> delete(key) end)
  end

  def get(key), do: ConCache.get(cache_name(), key)

  def get_or_store(key, function) do
    ConCache.get_or_store(cache_name(), key, fn() ->
      value = apply(function, [])
      %ConCache.Item{value: value, ttl: :infinity}
    end)
  end

  def get_or_store(key, ttl, function) do
    ConCache.get_or_store(cache_name(), key, fn() ->
      value = apply(function, [])
      %ConCache.Item{value: value, ttl: ttl}
    end)
  end

  def put(key, item), do: ConCache.put(cache_name(), key, item)

  def keys do
    cache_name()
    |> ConCache.ets
    |> :ets.tab2list
    |> Enum.map(&(elem(&1, 0)))
  end

  def podcasts do
    get_or_store("podcasts", :infinity, fn ->
      Podcast.active()
      |> Podcast.by_position()
      |> Podcast.preload_hosts()
      |> Repo.all()
    end)
  end
end
