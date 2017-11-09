defmodule ChangelogWeb.NewsController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsItem}

  def index(conn, params) do
    page = NewsItem
    |> NewsItem.published
    |> NewsItem.newest_first
    |> NewsItem.preload_all
    |> Repo.paginate(Map.put(params, :page_size, 15))

    render(conn, :index, items: page.entries, page: page)
  end

  def show(conn, %{"id" => id}) do
    item =
      NewsItem.published
      |> Repo.get_by!(id: id)
      |> NewsItem.preload_all

    render(conn, :show, item: item)
  end
end
