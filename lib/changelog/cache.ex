defmodule Changelog.Cache do
  @moduledoc """
  A small wrapper around ConCache to unify response/app caches
  """
  alias Changelog.{Episode, Podcast, Post}

  def delete(nil), do: :ok
  def delete(episode = %Episode{}) do
    episode = Episode.preload_podcast(episode)
    delete_prefix(:response_cache, "/#{episode.podcast.slug}/#{episode.slug}")
  end
  def delete(_podcast = %Podcast{}) do
    delete(:app_cache, "podcasts")
  end
  def delete(post = %Post{}) do
    delete(:response_cache, "/posts/#{post.slug}")
  end

  def delete(cache, key), do: ConCache.delete(cache, key)

  def delete_all do
    for cache <- [:app_cache, :response_cache] do
      cache
      |> keys()
      |> Enum.each(fn(key) -> delete(cache, key) end)
    end
  end

  def delete_prefix(cache, prefix) do
    cache
    |> keys()
    |> Enum.filter(fn(key) -> key =~ prefix end)
    |> Enum.each(fn(key) -> delete(cache, key) end)
  end

  def get_or_store(key, ttl, function) do
    ConCache.get_or_store(:app_cache, key, fn() ->
      value = apply(function, [])
      %ConCache.Item{value: value, ttl: ttl}
    end)
  end

  def keys(cache) do
    cache
    |> ConCache.ets
    |> :ets.tab2list
    |> Enum.map(&(elem(&1, 0)))
  end
end
