defmodule ChangelogWeb.NewsSourceController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsItem, NewsSource}

  def index(conn, params) do
    page =
      NewsSource
      |> NewsSource.with_news_items()
      |> order_by([q], asc: q.name)
      |> NewsSource.preload_news_items()
      |> Repo.paginate(Map.put(params, :page_size, 1000))

    render(conn, :index, sources: page.entries, page: page)
  end

  def show(conn, params = %{"slug" => slug}) do
    source = Repo.get_by!(NewsSource, slug: slug)

    page =
      NewsItem
      |> NewsItem.with_source(source)
      |> NewsItem.published()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(params)

    items =
      page.entries
      |> Enum.map(&NewsItem.load_object/1)

    render(conn, :show, source: source, items: items, page: page)
  end
end
