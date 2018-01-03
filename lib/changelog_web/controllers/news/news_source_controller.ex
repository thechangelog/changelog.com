defmodule ChangelogWeb.NewsSourceController do
  use ChangelogWeb, :controller

  alias Changelog.NewsSource

  def show(conn, %{"slug" => slug}) do
    source = Repo.get_by!(NewsSource, slug: slug) |> NewsSource.preload_news_items
    render(conn, :show, source: source)
  end
end
