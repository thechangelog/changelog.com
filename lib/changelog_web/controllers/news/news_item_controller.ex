defmodule ChangelogWeb.NewsItemController do
  use ChangelogWeb, :controller

  alias Changelog.{Hashid, NewsItem, NewsSponsorship}
  alias ChangelogWeb.NewsItemView

  plug RequireAdmin, "before preview" when action in [:preview]
  plug RequireUser, "before submitting" when action in [:new, :create]

  def index(conn, params) do
    pinned =
      NewsItem
      |> NewsItem.published
      |> NewsItem.pinned
      |> NewsItem.newest_first
      |> NewsItem.preload_all
      |> Repo.all
      |> Enum.map(&NewsItem.load_object/1)

    page =
      NewsItem
      |> NewsItem.published
      |> NewsItem.unpinned
      |> NewsItem.newest_first
      |> NewsItem.preload_all
      |> Repo.paginate(Map.put(params, :page_size, 20))

    ads =
      Timex.today
      |> NewsSponsorship.week_of
      |> NewsSponsorship.preload_all
      |> Repo.all
      |> Enum.take_random(2)
      |> Enum.map(&NewsSponsorship.ad_for_index/1)
      |> Enum.reject(&is_nil/1)

    items =
      page.entries
      |> Enum.map(&NewsItem.load_object/1)

    render(conn, :index, ads: ads, pinned: pinned, items: items, page: page)
  end

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
    hashid = slug |> String.split("-") |> List.last

    item =
      hashid
      |> item_from_hashid(NewsItem.published)
      |> NewsItem.preload_all
      |> NewsItem.load_object

    if slug == hashid do
      redirect(conn, to: news_item_path(conn, :show, NewsItemView.slug(item)))
    else
      render(conn, :show, item: item)
    end
  end

  def impress(conn = %{assigns: %{current_user: user}}, %{"items" => hashids}) do
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
      |> NewsItem.preload_all
      |> NewsItem.load_object

    render(conn, :show, item: item)
  end

  defp item_from_hashid(hashid, query \\ NewsItem) do
    Repo.get_by!(query, id: Hashid.decode(hashid))
  end

  defp should_track?(user, item) do
    NewsItem.is_published(item) && !is_admin?(user)
  end
end
