defmodule ChangelogWeb.TopicController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsItem, Topic}

  def index(conn, params) do
    page =
      Topic
      |> Topic.with_news_items
      |> order_by([q], asc: q.name)
      |> Topic.preload_news_items
      |> Repo.paginate(Map.put(params, :page_size, 1000))

    render(conn, :index, topics: page.entries, page: page)
  end

  def show(conn, params = %{"slug" => slug}) do
    topic = Repo.get_by!(Topic, slug: slug)

    page =
      NewsItem
      |> NewsItem.with_topic(topic)
      |> NewsItem.published
      |> NewsItem.newest_first
      |> NewsItem.preload_all
      |> Repo.paginate(params)

    render(conn, :show, topic: topic, items: page.entries, page: page)
  end
end
