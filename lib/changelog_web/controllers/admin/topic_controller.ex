defmodule ChangelogWeb.Admin.TopicController do
  use ChangelogWeb, :controller

  alias Changelog.Topic

  plug :scrub_params, "topic" when action in [:create, :update]

  def index(conn, _params) do
    topics =
      Topic
      |> order_by([c], asc: c.name)
      |> Repo.all

    render(conn, :index, topics: topics)
  end

  def new(conn, _params) do
    changeset = Topic.insert_changeset(%Topic{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"topic" => topic_params}) do
    changeset = Topic.insert_changeset(%Topic{}, topic_params)

    case Repo.insert(changeset) do
      {:ok, topic} ->
        Repo.update(Topic.file_changeset(topic, topic_params))

        conn
        |> put_flash(:result, "success")
        |> smart_redirect(topic, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    topic = Repo.get!(Topic, id)
    changeset = Topic.update_changeset(topic)
    render(conn, :edit, topic: topic, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "topic" => topic_params}) do
    topic = Repo.get!(Topic, id)
    changeset = Topic.update_changeset(topic, topic_params)

    case Repo.update(changeset) do
      {:ok, topic} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(topic, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, topic: topic, changeset: changeset)
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
