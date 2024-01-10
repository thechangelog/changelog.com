defmodule ChangelogWeb.TopicController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, Topic}

  def index(conn, params) do
    page =
      Topic
      |> Topic.with_news_items()
      |> order_by([q], asc: q.name)
      |> Topic.preload_news_items()
      |> Repo.paginate(Map.put(params, :page_size, 1000))

    render(conn, :index, topics: page.entries, page: page)
  end

  def show(conn, params = %{"slug" => slug}) do
    topic = Repo.get_by!(Topic, slug: slug)

    page =
      topic
      |> assoc(:episodes)
      |> Episode.published()
      |> Episode.newest_first()
      |> Episode.exclude_transcript()
      |> Episode.preload_all()
      |> Repo.paginate(params)

    conn
    |> assign(:topic, topic)
    |> assign(:page, page)
    |> render(:show)
  end

  def news(conn, %{"slug" => slug}) do
    conn
    |> put_status(301)
    |> redirect(to: ~p"/topic/#{slug}")
  end

  def podcasts(conn, %{"slug" => slug}) do
    conn
    |> put_status(301)
    |> redirect(to: ~p"/topic/#{slug}")
  end
end
