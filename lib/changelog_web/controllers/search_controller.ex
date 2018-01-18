defmodule ChangelogWeb.SearchController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsItem, SearchResults}

  require Logger

  def search(conn, params) do
    results = case params do
      %{"q" => query, "page" => page} -> fetch_results(query, page)
      %{"q" => query} -> fetch_results(query)
      _else -> nil
    end

    render(conn, "search.html", results: results, query: params["q"])
  end

  defp fetch_results(query, page \\ 1) do
    news = find_news(query, page)

    results(news)
  end

  defp results(news) do
    %SearchResults{
      count_total: news.total_entries,
      news: news
    }
  end

  defp find_news(query, page \\ 1, page_size \\ 10) do
    NewsItem
    |> NewsItem.published
    |> NewsItem.search(query)
    |> NewsItem.newest_first
    |> NewsItem.preload_all
    |> Repo.paginate(page: page, page_size: page_size)
  end
end
