defmodule ChangelogWeb.Plug.LoadPodcasts do
  import Plug.Conn

  alias Changelog.{Cache, Repo, Podcast}

  def init(opts), do: opts

  def call(conn, _opts) do
    assign(conn, :podcasts, cached_podcasts())
  end

  defp cached_podcasts do
    Cache.get_or_store("podcasts", :infinity, fn ->
      Podcast.active
      |> Podcast.ours
      |> Podcast.by_position
      |> Podcast.preload_hosts
      |> Repo.all
    end)
  end
end
