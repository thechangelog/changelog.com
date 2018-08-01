defmodule ChangelogWeb.Admin.TopicController do
  use ChangelogWeb, :controller

  alias Changelog.Topic

  plug :assign_topic when action in [:edit, :update, :delete]
  plug Authorize, [Policies.AdminsOnly, :topic]
  plug :scrub_params, "topic" when action in [:create, :update]

  def index(conn, _params) do
    topics =
      Topic
      |> order_by([q], asc: q.name)
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
        |> redirect_next(params, admin_topic_path(conn, :edit, topic.slug))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn = %{assigns: %{topic: topic}}, _params) do
    changeset = Topic.update_changeset(topic)
    render(conn, :edit, topic: topic, changeset: changeset)
  end

  def update(conn = %{assigns: %{topic: topic}}, params = %{"topic" => topic_params}) do
    changeset = Topic.update_changeset(topic, topic_params)

    case Repo.update(changeset) do
      {:ok, _topic} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_topic_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, topic: topic, changeset: changeset)
    end
  end

  def delete(conn = %{assigns: %{topic: topic}}, _params) do
    Repo.delete!(topic)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_topic_path(conn, :index))
  end

  defp assign_topic(conn = %{params: %{"id" => slug}}, _) do
    topic = Repo.get_by!(Topic, slug: slug)
    assign(conn, :topic, topic)
  end
end
