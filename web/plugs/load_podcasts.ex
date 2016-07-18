defmodule Changelog.Plug.LoadPodcasts do
  import Plug.Conn

  alias Changelog.{Repo, Podcast}

  def init(options) do
    options
  end

  def call(conn, _opts) do
    podcasts =
      Podcast.public
      |> Podcast.oldest_first
      |> Repo.all
      |> Podcast.preload_hosts

    assign(conn, :podcasts, podcasts)
  end
end
