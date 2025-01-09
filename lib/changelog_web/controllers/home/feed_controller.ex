defmodule ChangelogWeb.Home.FeedController do
  use ChangelogWeb, :controller

  alias Changelog.{Feed, Podcast}
  alias Changelog.ObanWorkers.{FeedUpdater, MailDeliverer}

  plug :assign_podcasts
  plug :assign_feed when action in [:edit, :update, :delete, :email, :refresh]
  plug Authorize, [Policies.Feed, :feed]
  plug :preload_current_user_extras

  def index(conn = %{assigns: %{current_user: me}}, _params) do
    feeds = me |> assoc(:feeds) |> Repo.all()

    conn
    |> assign(:feeds, feeds)
    |> render(:index)
  end

  def new(conn, _params) do
    changeset = Feed.insert_changeset(%Feed{})

    conn
    |> assign(:changeset, changeset)
    |> render(:new)
  end

  def create(conn = %{assigns: %{current_user: user}}, %{"feed" => feed_params}) do
    changeset = Feed.insert_changeset(%Feed{owner_id: user.id}, feed_params)

    case Repo.insert(changeset) do
      {:ok, feed} ->
        Repo.update(Feed.file_changeset(feed, feed_params))
        FeedUpdater.queue(feed)

        conn
        |> put_flash(:success, "Your new feed has been created! 👏")
        |> redirect(to: ~p"/~/feeds")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "There was a problem saving your feed. 😭")
        |> assign(:changeset, changeset)
        |> render(:new)
    end
  end

  def edit(conn = %{assigns: %{feed: feed}}, _params) do
    changeset = Feed.update_changeset(feed)
    render(conn, :edit, feed: feed, changeset: changeset)
  end

  def update(conn = %{assigns: %{feed: feed}}, params = %{"feed" => feed_params}) do
    changeset = Feed.update_changeset(feed, feed_params)

    case Repo.update(changeset) do
      {:ok, feed} ->
        FeedUpdater.queue(feed)

        conn
        |> put_flash(:success, "Your feed has been updated! ✨")
        |> redirect_next(params, ~p"/~/feeds")

      {:error, changeset} ->
        conn
        |> put_flash(:error, "There was a problem updating your feed. 😭")
        |> render(:edit, feed: feed, changeset: changeset)
    end
  end

  def delete(conn = %{assigns: %{feed: feed}}, params) do
    Repo.delete!(feed)

    conn
    |> put_flash(:success, "Your feed has been put out to pasture. 🐑")
    |> redirect_next(params, ~p"/~/feeds")
  end

  def email(conn = %{assigns: %{feed: feed}}, params) do
    MailDeliverer.queue("feed_links", %{"feed" => feed.id})

    conn
    |> put_flash(:success, "It should be in your inbox real soon 📥")
    |> redirect_next(params, ~p"/~/feeds")
  end

  def refresh(conn = %{assigns: %{feed: feed}}, params) do
    FeedUpdater.queue(feed)

    conn
    |> put_flash(:success, "Your feed is being rebuilt as we speak 🥂")
    |> redirect_next(params, ~p"/~/feeds")
  end

  defp preload_current_user_extras(conn = %{assigns: %{current_user: me}}, _) do
    me =
      me
      |> Repo.preload(:sponsors)
      |> Repo.preload(:active_membership)

    assign(conn, :current_user, me)
  end

  defp assign_feed(conn = %{params: %{"id" => id}}, _params) do
    feed = Feed |> Repo.get(id) |> Feed.preload_all()
    assign(conn, :feed, feed)
  end

  defp assign_podcasts(conn, _params) do
    podcasts =
      Podcast.public()
      |> Podcast.by_position()
      |> Repo.all()

    assign(conn, :podcasts, podcasts)
  end
end
