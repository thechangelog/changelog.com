defmodule Changelog.SearchController do
  use Changelog.Web, :controller

  alias Changelog.{Episode, Post}

  require Logger

  def search(conn, params) do
    case params do
      %{"q" => query} ->
        episodes = find_episodes(query)
        posts = find_posts(query)

        render(conn, "search.html", query: query, results: %{
          count: length(episodes) + length(posts),
          episodes: episodes,
          posts: posts
        })

      _else ->
        render(conn, "search.html", query: nil, results: nil)
    end
  end

  defp find_episodes(query, limit \\ 10) do
    Episode
    |> Episode.published
    |> Episode.search(query)
    |> Episode.newest_first
    |> Episode.limit(limit)
    |> Repo.all
    |> Episode.preload_podcast
    |> Episode.preload_guests
  end

  defp find_posts(query, limit \\ 10) do
    Post
    |> Post.published
    |> Post.search(query)
    |> Post.newest_first
    |> Post.limit(limit)
    |> Repo.all
    |> Post.preload_author
  end
end
