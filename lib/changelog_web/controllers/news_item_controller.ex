defmodule ChangelogWeb.NewsItemController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsItem, NewsItemComment, NewsSponsorship, Podcast, Subscription}
  alias ChangelogWeb.{NewsItemView, PersonView}

  plug RequireUser, "before submitting" when action in [:create]
  plug RequireUser, "before subscribing" when action in [:subscribe, :unsubscribe]

  def index(conn, params) do
    {page, unpinned} = NewsItem.get_unpinned_non_feed_news_items(params)
    unpinned = NewsItem.batch_load_objects(unpinned)

    # Only load pinned items for the first page
    pinned =
      if page.page_number == 1 do
        NewsItem.get_pinned_non_feed_news_items()
        |> NewsItem.batch_load_objects()
      else
        []
      end

    conn
    |> assign(:ads, get_ads())
    |> assign(:pinned, pinned)
    |> assign(:items, unpinned)
    |> assign(:page, page)
    |> render(:index)
  end

  def fresh(conn, params) do
    page =
      NewsItem
      |> NewsItem.published()
      |> NewsItem.non_feed_only()
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
      |> NewsItem.non_feed_only()
      |> NewsItem.sans_object()
      |> NewsItem.top_clicked_first()
      |> NewsItem.preload_all()

    query =
      case filter do
        "week" -> NewsItem.published_since(query, Timex.shift(Timex.now(), weeks: -1))
        "month" -> NewsItem.published_since(query, Timex.shift(Timex.now(), months: -1))
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

  def new(conn = %{assigns: %{current_user: user}}, _params) do
    changeset = NewsItem.submission_changeset(%NewsItem{})

    conn
    |> assign(:changeset, changeset)
    |> assign(:subscribed, news_subscriber?(user))
    |> render(:new)
  end

  def create(conn = %{assigns: %{current_user: user}}, %{"news_item" => item_params}) do
    item = %NewsItem{type: :link, author_id: user.id, submitter_id: user.id, status: :submitted}
    changeset = NewsItem.submission_changeset(item, item_params)

    if news_subscriber?(user) do
      case Repo.insert(changeset) do
        {:ok, _item} ->
          conn
          |> put_flash(:success, "We received your submission! Stay awesome 💚")
          |> redirect(to: Routes.root_path(conn, :index))

        {:error, changeset} ->
          conn
          |> put_flash(:error, "Something went wrong. 😭")
          |> assign(:changeset, changeset)
          |> render(:new)
      end
    else
      conn
      |> put_flash(:error, "You must subscribe to the Changelog Newsletter 📥")
      |> assign(:subscribed, false)
      |> assign(:changeset, changeset)
      |> render(:new)
    end
  end

  def show(conn, %{"id" => slug}) do
    hashid = slug |> String.split("-") |> List.last()
    item = item_from_hashid(hashid, NewsItem.published())

    cond do
      NewsItem.is_post(item) ->
        redirect(conn, to: NewsItemView.object_path(item))

      slug == hashid ->
        redirect(conn, to: Routes.news_item_path(conn, :show, NewsItem.slug(item)))

      true ->
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
    |> Enum.each(fn hashid ->
      item = item_from_hashid(hashid)

      if should_track?(user, item) do
        NewsItem.track_impression(item)
      end
    end)

    send_resp(conn, 204, "")
  end

  def visit(conn = %{method: "POST", assigns: %{current_user: user}}, %{"id" => hashid}) do
    item = item_from_hashid(hashid) |> NewsItem.preload_source()
    if should_track?(user, item), do: NewsItem.track_click(item)
    send_resp(conn, 204, "")
  end

  def visit(conn = %{assigns: %{current_user: user}}, %{"id" => hashid}) do
    item = item_from_hashid(hashid) |> NewsItem.preload_source()

    if should_track?(user, item), do: NewsItem.track_click(item)

    if item.object_id do
      redirect(conn, to: NewsItemView.object_path(item))
    else
      conn
      |> put_layout(false)
      |> render(:visit, to: NewsItemView.url(item))
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

  def subscribe(conn = %{assigns: %{current_user: user}}, %{"id" => hashid}) do
    item = item_from_hashid(hashid)
    context = "you clicked the 'Subscribe' link at the top of the discussion"
    Subscription.subscribe(user, item, context)

    conn
    |> put_flash(:success, "We'll email you when folks comment 📥")
    |> redirect(to: Routes.news_item_path(conn, :show, NewsItem.slug(item)))
  end

  def unsubscribe(conn = %{assigns: %{current_user: user}}, %{"id" => hashid}) do
    item = item_from_hashid(hashid)
    Subscription.unsubscribe(user, item)

    conn
    |> put_flash(:success, "No more email notifications from now on 🤐")
    |> redirect(to: Routes.news_item_path(conn, :show, NewsItem.slug(item)))
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
    Repo.get_by!(query, id: NewsItem.decode(hashid))
  end

  defp should_track?(user, item) do
    NewsItem.is_published(item) && !is_admin?(user)
  end

  defp news_subscriber?(nil), do: false

  defp news_subscriber?(user) do
    news = Repo.get_by(Podcast, slug: "news")
    PersonView.is_subscribed(user, news)
  end
end
