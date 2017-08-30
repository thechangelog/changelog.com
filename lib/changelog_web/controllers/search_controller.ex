defmodule ChangelogWeb.SearchController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, Post, SearchResults}

  require Logger

  def search(conn, params) do
    results = case params do
      %{"q" => query, "type" => type, "page" => page} -> fetch_results(query, type, page)
      %{"q" => query} -> fetch_results(query)
      _else -> nil
    end

    render(conn, "search.html", results: results, query: params["q"], type: params["type"])
  end

  defp fetch_results(query) do
    episodes = find_episodes(query)
    posts = find_posts(query)

    results(episodes, posts)
  end

  defp fetch_results(query, type, page) do
    episodes = if type == "episodes", do: find_episodes(query, page), else: %{total_entries: 0}
    posts = if type == "posts", do: find_posts(query, page), else: %{total_entries: 0}

    results(episodes, posts)
  end

  defp results(episodes, posts) do
    %SearchResults{
      count_total: episodes.total_entries + posts.total_entries,
      count_episodes: episodes.total_entries,
      count_posts: posts.total_entries,
      episodes: episodes,
      posts: posts
    }
  end

  defp find_episodes(query, page \\ 1, page_size \\ 10) do
    Episode
    |> Episode.published
    |> Episode.search(query)
    |> Episode.newest_first
    |> preload(:podcast)
    |> preload(:guests)
    |> Repo.paginate(page: page, page_size: page_size)
  end

  defp find_posts(query, page \\ 1, page_size \\ 10) do
    Post
    |> Post.published
    |> Post.search(query)
    |> Post.newest_first
    |> preload(:author)
    |> Repo.paginate(page: page, page_size: page_size)
  end
end
