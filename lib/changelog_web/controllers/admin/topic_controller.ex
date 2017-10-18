defmodule ChangelogWeb.Admin.TopicController do
  use ChangelogWeb, :controller

  alias Changelog.Topic

  plug :scrub_params, "topic" when action in [:create, :update]

  def index(conn, params) do
    page =
      Topic
      |> order_by([c], asc: c.name)
      |> Repo.paginate(params)

    render(conn, :index, topics: page.entries, page: page)
  end

  def new(conn, _params) do
    changeset = Topic.admin_changeset(%Topic{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params = %{"topic" => topic_params}) do
    changeset = Topic.admin_changeset(%Topic{}, topic_params)

    case Repo.insert(changeset) do
      {:ok, topic} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(topic, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    topic = Repo.get!(Topic, id)
    changeset = Topic.admin_changeset(topic)
    render(conn, "edit.html", topic: topic, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "topic" => topic_params}) do
    topic = Repo.get!(Topic, id)
    changeset = Topic.admin_changeset(topic, topic_params)

    case Repo.update(changeset) do
      {:ok, topic} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(topic, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("edit.html", topic: topic, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Repo.get!(Topic, id)
    Repo.delete!(topic)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_topic_path(conn, :index))
  end

  defp smart_redirect(conn, _topic, %{"close" => _true}) do
    redirect(conn, to: admin_topic_path(conn, :index))
  end
  defp smart_redirect(conn, topic, _params) do
    redirect(conn, to: admin_topic_path(conn, :edit, topic))
  end
end
