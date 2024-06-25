defmodule ChangelogWeb.NewsItemController do
  use ChangelogWeb, :controller

  alias Changelog.{Episode, NewsItem, NewsItemComment, Podcast, Subscription}
  alias ChangelogWeb.{EpisodeView, NewsItemView, PersonView}

  plug RequireUser, "before submitting" when action in [:create]
  plug RequireUser, "before subscribing" when action in [:subscribe, :unsubscribe]

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
          |> redirect(to: ~p"/")

        {:error, changeset} ->
          conn
          |> put_flash(:error, "Something went wrong. 😭")
          |> assign(:changeset, changeset)
          |> render(:new)
      end
    else
      conn
      |> put_flash(:error, "You must subscribe to Changelog News 📥")
      |> assign(:subscribed, false)
      |> assign(:changeset, changeset)
      |> render(:new)
    end
  end

  def show(conn, %{"id" => slug}) do
    # Changelog News gets its own special treatment
    try do
      podcast = Podcast.get_by_slug!("news")

      sub_count = Subscription.subscribed_count(podcast)

      episode =
        assoc(podcast, :episodes)
        |> Episode.published()
        |> Episode.preload_podcast()
        |> Repo.get_by!(slug: slug)

      previous =
        assoc(podcast, :episodes)
        |> Episode.previous_to(episode)
        |> Episode.newest_first(:published_at)
        |> Episode.preload_podcast()
        |> Episode.limit(1)
        |> Repo.one()

      conn
      |> assign(:sub_count, sub_count)
      |> assign(:podcast, podcast)
      |> assign(:episode, episode)
      |> assign(:previous, previous)
      |> put_view(EpisodeView)
      |> render(:news, layout: {ChangelogWeb.LayoutView, "news.html"})
    rescue
      _e -> false
    end

    hashid = slug |> String.split("-") |> List.last()
    item = item_from_hashid(hashid, NewsItem.published())

    cond do
      NewsItem.is_post(item) ->
        redirect(conn, to: NewsItemView.object_path(item))

      slug == hashid ->
        redirect(conn, to: ~p"/news/#{NewsItem.slug(item)}")

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
      |> render(:visit, to: NewsItemView.news_item_url(item))
    end
  end

  # if this is a Changelog News episode, preview that instead
  def preview(conn, %{"id" => id}) do
    try do
      podcast = Podcast.get_by_slug!("news")

      episode =
        assoc(podcast, :episodes)
        |> Episode.preload_all()
        |> Repo.get_by!(slug: id)
        |> Episode.load_news_item()

      conn
      |> assign(:podcast, podcast)
      |> assign(:episode, episode)
      |> assign(:item, episode.news_item)
      |> put_view(EpisodeView)
      |> render(:show)
    rescue
      _e -> false
    end

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
    |> redirect(to: ~p"/news/#{NewsItem.slug(item)}")
  end

  def unsubscribe(conn = %{assigns: %{current_user: user}}, %{"id" => hashid}) do
    item = item_from_hashid(hashid)
    Subscription.unsubscribe(user, item)

    conn
    |> put_flash(:success, "No more email notifications from now on 🤐")
    |> redirect(to: ~p"/news/#{NewsItem.slug(item)}")
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
