defmodule ChangelogWeb.SearchController do
  use ChangelogWeb, :controller

  alias Changelog.NewsItem

  require Logger

  def search(conn, params = %{"q" => query}) do
    page =
      NewsItem
      |> NewsItem.published
      |> NewsItem.search(query)
      |> NewsItem.newest_first
      |> NewsItem.preload_all
      |> Repo.paginate(Map.put(params, :page_size, 30))

    items =
      page.entries
      |> Enum.map(&NewsItem.load_object/1)

    render(conn, :search, items: items, page: page, query: params["q"])
  end

  def search(conn, _params) do
    render(conn, :search, items: [], query: "")
  end
end
