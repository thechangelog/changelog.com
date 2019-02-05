defmodule ChangelogWeb.JsonFeedController do
  use ChangelogWeb, :controller

  alias Changelog.NewsItem

  require Logger

  def news(conn, _params) do
    conn
    |> put_layout(false)
    |> put_resp_content_type("application/json")
    |> cache_public(:timer.minutes(5))
    |> render("news.json", items: NewsItem.latest_news_items())
  end
end
