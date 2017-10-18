defmodule ChangelogWeb.Admin.NewsItemController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsItem, NewsQueue}

  plug :scrub_params, "news_item" when action in [:create, :update]

  def index(conn, params) do
    queued =
      NewsQueue.ordered
      |> NewsQueue.preload_all
      |> Repo.all
      |> Enum.map(&(&1.item))

    page =
      NewsItem.published
      |> NewsItem.newest_first
      |> NewsItem.preload_all
      |> Repo.paginate(params)

    render(conn, :index, queued: queued, published: page.entries, page: page)
  end

  def new(conn, _params) do
    changeset =
      conn.assigns.current_user
      |> build_assoc(:logged_news_items)
      |> NewsItem.insert_changeset()

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params = %{"news_item" => news_item_params}) do
    changeset = NewsItem.insert_changeset(%NewsItem{}, news_item_params)

    case Repo.insert(changeset) do
      {:ok, news_item} ->
        Repo.update(NewsItem.file_changeset(news_item, news_item_params))

        case Map.get(params, "queue", "append") do
          "publish" -> NewsItem.publish!(news_item)
          "prepend" -> NewsQueue.prepend(news_item)
          "append" -> NewsQueue.append(news_item)
        end

        conn
        |> put_flash(:result, "success")
        |> redirect(to: admin_news_item_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    news_item = Repo.get!(NewsItem, id) |> NewsItem.preload_topics()
    changeset = NewsItem.update_changeset(news_item)
    render(conn, "edit.html", news_item: news_item, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "news_item" => news_item_params}) do
    news_item = Repo.get!(NewsItem, id) |> NewsItem.preload_topics()
    changeset = NewsItem.update_changeset(news_item, news_item_params)

    case Repo.update(changeset) do
      {:ok, news_item} ->
        conn
        |> put_flash(:result, "success")
        |> smart_redirect(news_item, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("edit.html", news_item: news_item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    news_item = Repo.get!(NewsItem, id)
    Repo.delete!(news_item)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_news_item_path(conn, :index))
  end

  def move(conn, %{"id" => id, "position" => position}) do
    news_item = Repo.get!(NewsItem, id)
    NewsQueue.move(news_item, String.to_integer(position))
    send_resp(conn, 200, "")
  end

  defp smart_redirect(conn, _item, %{"close" => _true}) do
    redirect(conn, to: admin_news_item_path(conn, :index))
  end
  defp smart_redirect(conn, item, _params) do
    redirect(conn, to: admin_news_item_path(conn, :edit, item))
  end
end
