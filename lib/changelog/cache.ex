defmodule Changelog.Cache do
  @moduledoc """
  A small wrapper around ConCache to unify response/app caches
  """

  alias Changelog.{Episode, Podcast, Post}

  def get_or_store(key, ttl, function) do
    ConCache.get_or_store(:app_cache, key, fn() ->
      value = apply(function, [])
      %ConCache.Item{value: value, ttl: ttl}
    end)
  end

  def delete(nil), do: :ok
  def delete(%Episode{} = episode) do
    episode = Episode.preload_podcast(episode)
    ConCache.delete(:response_cache, "/#{episode.podcast.slug}/#{episode.slug}")
  end
  def delete(%Podcast{} = podcast) do
    ConCache.delete(:app_cache, "podcasts")
    ConCache.delete(:response_cache, "/#{podcast.slug}")
  end
  def delete(%Post{} = post) do
    ConCache.delete(:response_cache, "/posts/#{post.slug}")
  end

  def delete_all do
    for cache <- [:app_cache, :response_cache] do
      cache
      |> ConCache.ets
      |> :ets.tab2list
      |> Enum.each(fn({key, _}) -> ConCache.delete(cache, key) end)
    end
  end
end
