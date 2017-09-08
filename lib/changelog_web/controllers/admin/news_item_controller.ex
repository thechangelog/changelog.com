defmodule ChangelogWeb.Admin.NewsItemController do
  use ChangelogWeb, :controller

  alias Changelog.NewsItem

  plug :scrub_params, "news_item" when action in [:create, :update]

  def index(conn, params) do
    page =
      NewsItem.published
      |> NewsItem.newest_first
      |> NewsItem.preload_all
      |> Repo.paginate(params)

    render(conn, :index, items: page.entries, page: page)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns.current_user
      |> build_assoc(:news_items)
      |> NewsItem.admin_changeset()

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params = %{"news_item" => item_params}) do
    changeset = NewsItem.admin_changeset(%NewsItem{}, item_params)

    case Repo.insert(changeset) do
      {:ok, item} ->
        # queue_action = Map.get(params, "queue", "last")
        # NewsQueue.action(queue_action, item)
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(item, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    item = Repo.get!(NewsItem, id) |> NewsItem.preload_all
    changeset = NewsItem.admin_changeset(item)
    render(conn, "edit.html", item: item, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "news_item" => item_params}) do
    item = Repo.get!(NewsItem, id) |> NewsItem.preload_all
    changeset = NewsItem.admin_changeset(item, item_params)

    case Repo.update(changeset) do
      {:ok, item} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(item, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("edit.html", item: item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Repo.get!(NewsItem, id)
    Repo.delete!(item)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_news_item_path(conn, :index))
  end

  defp smart_redirect(conn, _item, %{"close" => _true}) do
    redirect(conn, to: admin_news_item_path(conn, :index))
  end
  defp smart_redirect(conn, item, _params) do
    redirect(conn, to: admin_news_item_path(conn, :edit, item))
  end
end
