defmodule ChangelogWeb.SearchController do
  use ChangelogWeb, :controller

  alias Changelog.{Search}

  require Logger

  def search(conn, params = %{"q" => query}) do
    page = Search.search(query, [hitsPerPage: 30, page: Map.get(params, "page", 0)])
    render(conn, :search, items: page.items, page: page, query: params["q"])
  end

  def search(conn, _params) do
    render(conn, :search, items: [], page: %{total_entries: 0}, query: "")
  end
end
