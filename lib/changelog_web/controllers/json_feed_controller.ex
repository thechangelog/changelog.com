defmodule ChangelogWeb.JsonFeedController do
  use ChangelogWeb, :controller

  alias Changelog.NewsItem

  require Logger

  plug PublicEtsCache

  def news(conn, _params) do
    conn
    |> put_layout(false)
    |> put_resp_content_type("application/json")
    |> render("news.json", items: NewsItem.latest_news_items())
    |> cache_public_response()
  end
end
