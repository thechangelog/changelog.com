defmodule ChangelogWeb.TopicController do
  use ChangelogWeb, :controller

  alias Changelog.Topic

  def index(conn, params) do
    page =
      Topic
      |> order_by([q], desc: q.name)
      |> Topic.preload_news_items
      |> Repo.paginate(params)

    render(conn, :index, topics: page.entries, page: page)
  end

  def show(conn, %{"slug" => slug}) do
    topic = Repo.get_by!(Topic, slug: slug) |> Topic.preload_news_items
    render(conn, :show, topic: topic)
  end
end
