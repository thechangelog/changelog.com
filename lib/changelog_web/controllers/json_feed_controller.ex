defmodule ChangelogWeb.JsonFeedController do
  use ChangelogWeb, :controller
  use PlugEtsCache.Phoenix

  alias Changelog.NewsItem

  require Logger

  def news(conn, _params) do
    conn
    |> put_layout(false)
    |> put_resp_content_type("application/json")
    |> render("news.json", items: NewsItem.latest_news_items)
    |> cache_response
  end
end
