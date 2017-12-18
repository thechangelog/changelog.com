defmodule ChangelogWeb.Admin.NewsItemController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsItem, NewsQueue, UrlKit}

  plug :scrub_params, "news_item" when action in [:create, :update]
  plug :detect_quick_form when action in [:new, :create]

  def index(conn = %{assigns: %{current_user: me}}, params) do
    drafts =
      NewsItem.drafted
      |> NewsItem.newest_last
      |> NewsItem.logged_by(me)
      |> NewsItem.preload_all
      |> Repo.all

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

    render(conn, :index, drafts: drafts, queued: queued, published: page.entries, page: page)
  end

  def new(conn, params) do
    url = UrlKit.normalize_url(params["url"])

    changeset =
      conn.assigns.current_user
      |> build_assoc(:logged_news_items,
        url: url,
        headline: UrlKit.get_title(url),
        source: UrlKit.get_source(url),
        type: UrlKit.get_type(url))
      |> NewsItem.insert_changeset()

    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"news_item" => item_params}) do
    changeset = NewsItem.insert_changeset(%NewsItem{}, item_params)

    case Repo.insert(changeset) do
      {:ok, item} ->
        Repo.update(NewsItem.file_changeset(item, item_params))
        handle_status_changes(item, params)

        if conn.assigns.quick do
          render(conn, :create, layout: false)
        else
          conn
          |> put_flash(:result, "success")
          |> redirect(to: admin_news_item_path(conn, :index))
        end
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    item = Repo.get!(NewsItem, id) |> NewsItem.preload_topics()
    changeset = NewsItem.update_changeset(item)
    render(conn, :edit, item: item, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "news_item" => item_params}) do
    item = Repo.get!(NewsItem, id) |> NewsItem.preload_topics()
    changeset = NewsItem.update_changeset(item, item_params)

    case Repo.update(changeset) do
      {:ok, item} ->
        handle_status_changes(item, params)

        conn
        |> put_flash(:result, "success")
        |> smart_redirect(item, params)
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, item: item, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    item = Repo.get!(NewsItem, id)
    Repo.delete!(item)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_news_item_path(conn, :index))
  end

  def move(conn, %{"id" => id, "position" => position}) do
    item = Repo.get!(NewsItem, id)
    NewsQueue.move(item, String.to_integer(position))
    send_resp(conn, 200, "")
  end

  defp detect_quick_form(conn, _opts) do
    assign(conn, :quick, Map.has_key?(conn.params, "quick"))
  end

  defp handle_status_changes(item, params) do
    case Map.get(params, "queue", "draft") do
      "publish" -> NewsQueue.publish(item)
      "prepend" -> NewsQueue.prepend(item)
      "append"  -> NewsQueue.append(item)
      "draft"   -> true
    end
  end

  # usually we want to stay on edit as the default, but in this case we
  # actually want to close as the default and let stay be the exception case
  defp smart_redirect(conn, item, %{"stay" => _true}) do
    redirect(conn, to: admin_news_item_path(conn, :edit, item))
  end
  defp smart_redirect(conn, _item, _params) do
    redirect(conn, to: admin_news_item_path(conn, :index))
  end
end
