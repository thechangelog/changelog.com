defmodule ChangelogWeb.Plug.LoadPodcasts do
  import Plug.Conn

  alias Changelog.{Repo, Podcast}

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(conn, :podcasts, cached_podcasts())
  end

  defp cached_podcasts do
    ConCache.get_or_store(:app_cache, "podcasts", fn() ->
      podcasts =
        Podcast.active
        |> Podcast.ours
        |> Podcast.oldest_first
        |> Podcast.preload_hosts
        |> Repo.all

      %ConCache.Item{value: podcasts, ttl: :infinity}
    end)
  end
end
