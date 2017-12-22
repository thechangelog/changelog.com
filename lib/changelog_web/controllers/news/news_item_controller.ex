defmodule ChangelogWeb.NewsItemController do
  use ChangelogWeb, :controller

  alias Changelog.{Hashid, NewsItem}
  alias ChangelogWeb.NewsItemView

  plug RequireAdmin, "before preview" when action in [:index, :preview]
  plug :put_layout, false

  def index(conn, params) do
    page = NewsItem
    |> NewsItem.published
    |> NewsItem.newest_first
    |> NewsItem.preload_all
    |> Repo.paginate(Map.put(params, :page_size, 15))

    render(conn, :index, items: page.entries, page: page)
  end

  def show(conn, %{"id" => slug}) do
    hashid = slug |> String.split("-") |> List.last

    item =
      NewsItem.published
      |> Repo.get_by!(id: Hashid.decode(hashid))
      |> NewsItem.preload_all

    if slug == hashid do
      redirect(conn, to: news_item_path(conn, :show, NewsItemView.slug(item)))
    else
      render(conn, :show, item: item)
    end
  end

  def preview(conn, %{"id" => id}) do
    item =
      NewsItem
      |> Repo.get_by!(id: id)
      |> NewsItem.preload_all

    render(conn, :show, item: item)
  end
end
