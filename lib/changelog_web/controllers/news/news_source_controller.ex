defmodule ChangelogWeb.NewsSourceController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsItem, NewsSource}

  def show(conn, params = %{"slug" => slug}) do
    source = Repo.get_by!(NewsSource, slug: slug)

    page =
      NewsItem
      |> NewsItem.with_source(source)
      |> NewsItem.published
      |> NewsItem.newest_first
      |> NewsItem.preload_all
      |> Repo.paginate(params)

    render(conn, :show, source: source, items: page.entries, page: page)
  end
end
