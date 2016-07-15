defmodule Changelog.Plug.LoadPodcasts do
  import Plug.Conn
  import Ecto.Query

  alias Changelog.{Repo, Podcast}

  def init(options) do
    options
  end

  def call(conn, _opts) do
    podcasts =
      Repo.all(from p in Podcast, order_by: [asc: p.id])
      |> Podcast.preload_hosts

    assign(conn, :podcasts, podcasts)
  end
end
