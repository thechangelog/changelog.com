defmodule ChangelogWeb.TopicController do
  use ChangelogWeb, :controller

  alias Changelog.Topic

  def index(conn, params) do
    page =
      Topic
      |> order_by([q], desc: q.name)
      |> Repo.paginate(params)

    render(conn, :index, topics: page.entries, page: page)
  end

  def show(conn, params = %{"id" => slug}) do
    topic = Repo.get_by!(Topic, slug: slug)
    render(conn, :show, topic: topic)
  end
end
