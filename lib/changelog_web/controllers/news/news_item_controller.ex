defmodule ChangelogWeb.NewsItemController do
  use ChangelogWeb, :controller

  alias Changelog.{Hashid, NewsItem, NewsItemComment, NewsSponsorship}
  alias ChangelogWeb.NewsItemView

  plug RequireUser, "before submitting" when action in [:create]

  def index(conn, params) do
    pinned =
      NewsItem
      |> NewsItem.published()
      |> NewsItem.pinned()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.all()
      |> Enum.map(&NewsItem.load_object/1)

    page =
      NewsItem
      |> NewsItem.published()
      |> NewsItem.unpinned()
      |> NewsItem.newest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 20))

    items = Enum.map(page.entries, &NewsItem.load_object/1)

    conn
    |> assign(:ads, get_ads())
    |> assign(:pinned, pinned)
    |> assign(:items, items)
    |> assign(:page, page)
    |> render(:index)
  end

  def fresh(conn, params) do
    page =
      NewsItem
      |> NewsItem.published()
      |> NewsItem.freshest_first()
      |> NewsItem.preload_all()
      |> Repo.paginate(Map.put(params, :page_size, 20))

    items = Enum.map(page.entries, &NewsItem.load_object/1)

    render(conn, :fresh, ads: get_ads(), items: items, page: page)
  end

  def top_week(conn, params), do: top(conn, Map.merge(params, %{"filter" => "week"}))
  def top_month(conn, params), do: top(conn, Map.merge(params, %{"filter" => "month"}))
  def top_all(conn, params), do: top(conn, Map.merge(params, %{"filter" => "all"}))

  def top(conn, params = %{"filter" => filter}) do
    query =
      NewsItem
      |> NewsItem.published()
      |> NewsItem.sans_object()
      |> NewsItem.top_clicked_first()
      |> NewsItem.preload_all()

    query = case filter do
      "week" -> NewsItem.published_since(query, Timex.shift(Timex.now, weeks: -1))
      "month" -> NewsItem.published_since(query, Timex.shift(Timex.now, months: -1))
      _else -> query
    end

    page = Repo.paginate(query, Map.put(params, :page_size, 20))
    items = Enum.map(page.entries, &NewsItem.load_object/1)

    conn
    |> assign(:filter, filter)
    |> assign(:items, items)
    |> assign(:ads, get_ads())
    |> assign(:page, page)
    |> render(:top)
  end
  def top(conn, params), do: top(conn, Map.merge(params, %{"filter" => "week"}))

  def new(conn, _params) do
    changeset = NewsItem.submission_changeset(%NewsItem{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn = %{assigns: %{current_user: user}}, %{"news_item" => item_params}) do
    item = %NewsItem{type: :link, author_id: user.id, submitter_id: user.id, status: :submitted}
    changeset = NewsItem.submission_changeset(item, item_params)

    case Repo.insert(changeset) do
      {:ok, _item} ->
        conn
        |> put_flash(:success, "We received your submission! Stay awesome 💚")
        |> redirect(to: root_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:error, "Something went wrong. 😭")
        |> render(:new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => slug}) do
    hashid = slug |> String.split("-") |> List.last()
    item = item_from_hashid(hashid, NewsItem.published)

    if slug == hashid do
      redirect(conn, to: news_item_path(conn, :show, NewsItemView.slug(item)))
    else
      item =
        item
        |> NewsItem.preload_all()
        |> NewsItem.preload_comments()
        |> NewsItem.load_object()

      comments = NewsItemComment.nested(item.comments)
      changeset = item |> build_assoc(:comments) |> NewsItemComment.insert_changeset()

      conn
      |> assign(:item, item)
      |> assign(:comments, comments)
      |> assign(:changeset, changeset)
      |> render(:show)
    end
  end

  def impress(conn, %{"items" => hashids}), do: impress(conn, %{"ids" => hashids})
  def impress(conn = %{assigns: %{current_user: user}}, %{"ids" => hashids}) do
    hashids
    |> String.split(",")
    |> Enum.each(fn(hashid) ->
      item = item_from_hashid(hashid)
      if should_track?(user, item) do
        NewsItem.track_impression(item)
      end
    end)

    send_resp(conn, 204, "")
  end

  def visit(conn = %{assigns: %{current_user: user}}, %{"id" => hashid}) do
    item = item_from_hashid(hashid)

    if should_track?(user, item), do: NewsItem.track_click(item)

    if item.object_id do
      redirect(conn, to: NewsItemView.object_path(item))
    else
      conn
      |> put_layout(false)
      |> render(:visit, to: item.url)
    end
  end

  def preview(conn, %{"id" => id}) do
    item =
      NewsItem
      |> Repo.get_by!(id: id)
      |> NewsItem.preload_all()
      |> NewsItem.load_object()

    changeset = item |> build_assoc(:comments) |> NewsItemComment.insert_changeset()

    conn
    |> assign(:item, item)
    |> assign(:comments, [])
    |> assign(:changeset, changeset)
    |> render(:show)
  end

  defp get_ads do
    Timex.today()
    |> NewsSponsorship.week_of()
    |> NewsSponsorship.preload_all()
    |> Repo.all()
    |> Enum.take_random(2)
    |> Enum.map(&NewsSponsorship.ad_for_index/1)
    |> Enum.reject(&is_nil/1)
  end

  defp item_from_hashid(hashid, query \\ NewsItem) do
    Repo.get_by!(query, id: Hashid.decode(hashid))
  end

  defp should_track?(user, item) do
    NewsItem.is_published(item) && !is_admin?(user)
  end
end
