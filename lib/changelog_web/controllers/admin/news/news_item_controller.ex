defmodule ChangelogWeb.Admin.NewsItemController do
  use ChangelogWeb, :controller

  alias Changelog.{HtmlKit, NewsItem, NewsSource, NewsQueue, Topic, UrlKit}

  plug :scrub_params, "news_item" when action in [:create, :update]
  plug :detect_quick_form when action in [:new, :create]

  def index(conn = %{assigns: %{current_user: me}}, params) do
    drafts =
      NewsItem.drafted
      |> NewsItem.newest_first(:inserted_at)
      |> NewsItem.logged_by(me)
      |> NewsItem.preload_all
      |> Repo.all

    queued =
      NewsQueue.queued
      |> NewsQueue.preload_all
      |> Repo.all
      |> Enum.map(&(&1.item))

    scheduled =
      NewsQueue.scheduled
      |> NewsQueue.preload_all
      |> Repo.all
      |> Enum.map(&(&1.item))

    submitted =
      NewsItem.submitted
      |> NewsItem.newest_first(:inserted_at)
      |> NewsItem.preload_all
      |> Repo.all

    page =
      NewsItem.published
      |> NewsItem.newest_first
      |> NewsItem.preload_all
      |> Repo.paginate(params)

    activity_count = 5

    topic_activity =
      Topic
      |> Topic.newest_first(:updated_at)
      |> Topic.limit(activity_count)
      |> Repo.all

    source_activity =
      NewsSource
      |> NewsSource.newest_first(:updated_at)
      |> NewsSource.limit(activity_count)
      |> Repo.all

    activity =
      (topic_activity ++ source_activity)
      |> Enum.sort(&(Timex.after?(&1.updated_at, &2.updated_at)))
      |> Enum.chunk(activity_count)

    render(conn, :index, drafts: drafts, submitted: submitted, queued: queued,
                         scheduled: scheduled, activity: activity,
                         published: page.entries, page: page)
  end

  def new(conn = %{assigns: %{current_user: me}}, params) do
    url = UrlKit.normalize_url(params["url"])
    html = UrlKit.get_html(url)

    changeset =
      me
      |> build_assoc(:logged_news_items,
        url: url,
        headline: String.capitalize(HtmlKit.get_title(html)),
        source: UrlKit.get_source(url),
        type: UrlKit.get_type(url))
      |> NewsItem.insert_changeset()

    images = HtmlKit.get_images(html)

    render(conn, :new, changeset: changeset, images: images)
  end

  def create(conn, params = %{"news_item" => item_params}) do
    item_params = detect_object_id(item_params)
    changeset = NewsItem.insert_changeset(%NewsItem{}, item_params)

    case Repo.insert(changeset) do
      {:ok, item} ->
        Repo.update(NewsItem.file_changeset(item, item_params))
        handle_status_changes(item, params)

        conn
        |> put_flash(:result, "success")
        |> redirect(to: determine_redirect(conn, item, params))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:new, changeset: changeset)
    end
  end

  def edit(conn = %{assigns: %{current_user: me}}, %{"id" => id}) do
    item = Repo.get!(NewsItem, id) |> NewsItem.preload_topics()
    changeset = NewsItem.update_changeset(item, %{logger_id: item.logger_id || me.id})
    render(conn, :edit, item: item, changeset: changeset)
  end

  def update(conn, params = %{"id" => id, "news_item" => item_params}) do
    item_params = detect_object_id(item_params)
    item = Repo.get!(NewsItem, id) |> NewsItem.preload_topics()
    changeset = NewsItem.update_changeset(item, item_params)

    case Repo.update(changeset) do
      {:ok, item} ->
        handle_status_changes(item, params)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, determine_redirect(conn, item, params))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, item: item, changeset: changeset)
    end
  end

  def decline(conn, %{"id" => id}) do
    item = Repo.get!(NewsItem, id)
    NewsItem.decline!(item)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_news_item_path(conn, :index))
  end

  def delete(conn, %{"id" => id}) do
    item = Repo.get!(NewsItem, id)
    Repo.delete!(item)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_news_item_path(conn, :index))
  end

  def unpublish(conn, %{"id" => id}) do
    item = Repo.get!(NewsItem, id)
    NewsItem.unpublish!(item)

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

  defp detect_object_id(item_params = %{"type" => type, "url" => url}) do
    Map.put_new(item_params, "object_id", UrlKit.get_object_id(type, url))
  end
  defp detect_object_id(item_params), do: item_params

  defp determine_redirect(conn, item, params) do
    case Map.get(params, "queue", "draft") do
      "draft" -> admin_news_item_path(conn, :edit, item)
      _else   -> admin_news_item_path(conn, :index)
    end
  end

  defp handle_status_changes(item, params) do
    case Map.get(params, "queue", "draft") do
      "publish" -> NewsQueue.publish(item)
      "prepend" -> NewsQueue.prepend(item)
      "append"  -> NewsQueue.append(item)
      "draft"   -> true
    end
  end
end
