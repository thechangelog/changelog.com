defmodule ChangelogWeb.SearchController do
  use ChangelogWeb, :controller

  alias Changelog.TypesenseSearch
  # alias Changelog.Search
  # alias Changelog.LocalSearch

  require Logger

  def search(conn, params = %{"q" => query}) do
    query_fields = "headline,story,fragment"
    page = TypesenseSearch.search_with_highlights(
      q: query,
      query_by: query_fields,
      sort_by: "_text_match:desc,published_at:desc",
      highlight_full_fields: query_fields,
      highlight_start_tag: "<em>",
      highlight_end_tag: "</em>",
      per_page: 30,
      page: page_param(params) + 1
    )
    # page = Search.search_with_highlights(query, hitsPerPage: 30, page: page_param(params))
    # page = LocalSearch.search_with_highlights(query, hitsPerPage: 30, page: page_param(params))
    render(conn, :search, items: page.entries, page: page, query: query)
  end

  def search(conn, _params) do
    render(conn, :search, items: [], page: %{total_entries: 0}, query: "")
  end

  defp page_param(params) do
    try do
      params |> Map.get("page", 0) |> String.to_integer()
    rescue
      _e in ArgumentError -> 0
    end
  end
end
