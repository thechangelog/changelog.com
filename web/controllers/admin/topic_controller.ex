defmodule Changelog.Admin.TopicController do
  use Changelog.Web, :controller

  alias Changelog.Topic

  plug :scrub_params, "topic" when action in [:create, :update]

  def index(conn, _params) do
    topics = Repo.all from p in Topic, order_by: p.id
    render conn, "index.html", topics: topics
  end

  def new(conn, _params) do
    changeset = Topic.changeset(%Topic{})
    render conn, "new.html", changeset: changeset
  end

  def create(conn, %{"topic" => topic_params}) do
    changeset = Topic.changeset(%Topic{}, topic_params)

    case Repo.insert(changeset) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "#{topic.name} created!")
        |> redirect(to: admin_topic_path(conn, :index))
      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    topic = Repo.get!(Topic, id)
    changeset = Topic.changeset(topic)
    render conn, "edit.html", topic: topic, changeset: changeset
  end

  def update(conn, %{"id" => id, "topic" => topic_params}) do
    topic = Repo.get!(Topic, id)
    changeset = Topic.changeset(topic, topic_params)

    case Repo.update(changeset) do
      {:ok, topic} ->
        conn
        |> put_flash(:info, "#{topic.name} udated!")
        |> redirect(to: admin_topic_path(conn, :index))
      {:error, changeset} ->
        render conn, "edit.html", topic: topic, changeset: changeset
    end
  end

  def delete(conn, %{"id" => id}) do
    topic = Repo.get!(Topic, id)
    Repo.delete!(topic)

    conn
    |> put_flash(:info, "#{topic.name} deleted!")
    |> redirect(to: admin_topic_path(conn, :index))
  end
end
