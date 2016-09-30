defmodule Changelog.FeedController do
  use Changelog.Web, :controller

  alias Changelog.{Episode, Post}

  def sitemap(conn, _params) do
    episodes =
      Episode.published
      |> Episode.newest_first
      |> Repo.all
      |> Episode.preload_podcast

    posts =
      Post.published
      |> Post.newest_first
      |> Repo.all

    conn
    |> put_layout(false)
    |> render("sitemap.xml", episodes: episodes, posts: posts)
  end
end
