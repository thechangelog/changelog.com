defmodule ChangelogWeb.SearchController do
  use ChangelogWeb, :controller

  alias Changelog.TypesenseSearch
  # alias Changelog.LocalSearch

  require Logger

  def search(conn, params = %{"q" => query}) when is_binary(query) and bit_size(query) > 0 do
    query_fields = "headline,story,fragment"

    page =
      TypesenseSearch.search_with_highlights(
        q: query,
        query_by: query_fields,
        sort_by: "_text_match:desc,published_at:desc",
        highlight_full_fields: query_fields,
        group_by: "item_id",
        group_limit: "1",
        typo_tokens_threshold: 100,
        drop_tokens_threshold: 100,
        highlight_start_tag: "<mark>",
        highlight_end_tag: "</mark>",
        per_page: 30,
        page: page_param(params) + 1
      )

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
