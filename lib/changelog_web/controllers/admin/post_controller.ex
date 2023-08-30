defmodule ChangelogWeb.Admin.PostController do
  use ChangelogWeb, :controller

  alias Changelog.{Cache, NewsQueue, Post, PostNewsItem}
  alias Changelog.ObanWorkers.FeedUpdater

  plug :assign_post when action in [:edit, :update, :delete, :publish, :unpublish]
  plug Authorize, [Policies.Admin.Post, :post]
  plug :scrub_params, "post" when action in [:create, :update]

  def index(conn = %{assigns: %{current_user: me}}, params) do
    page =
      Post.published()
      |> Post.newest_first()
      |> preload(:author)
      |> Repo.paginate(params)

    scheduled =
      Post.scheduled()
      |> Post.newest_first()
      |> preload(:author)
      |> Repo.all()

    drafts =
      if(me.admin, do: Post, else: Post.contributed_by(me))
      |> Post.unpublished()
      |> Post.newest_first(:inserted_at)
      |> preload(:author)
      |> preload(:editor)
      |> Repo.all()

    conn
    |> assign(:posts, page.entries)
    |> assign(:scheduled, scheduled)
    |> assign(:drafts, drafts)
    |> assign(:page, page)
    |> render(:index)
  end

  def new(conn, _params) do
    changeset = Post.insert_changeset(%Post{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, params = %{"post" => post_params}) do
    changeset = Post.insert_changeset(%Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, post} ->
        Repo.update(Post.file_changeset(post, post_params))

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/posts/#{post}/edit")

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn = %{assigns: %{post: post}}, _params) do
    post = Post.preload_all(post)
    changeset = Post.update_changeset(post)
    render(conn, :edit, post: post, changeset: changeset)
  end

  def update(conn = %{assigns: %{post: post}}, params = %{"post" => post_params}) do
    post = Post.preload_all(post)
    changeset = Post.update_changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        PostNewsItem.update(post)
        handle_feed_updates(post)
        Cache.delete(post)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/posts")

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, post: post, changeset: changeset)
    end
  end

  def delete(conn = %{assigns: %{post: post}}, _params) do
    Repo.delete!(post)
    PostNewsItem.delete(post)
    handle_feed_updates(post)
    Cache.delete(post)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: ~p"/admin/posts")
  end

  def publish(conn = %{assigns: %{post: post}}, params) do
    changeset = Ecto.Changeset.change(post, %{published: true})

    case Repo.update(changeset) do
      {:ok, post} ->
        handle_news_item(conn, post)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/posts")

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, post: post, changeset: changeset)
    end
  end

  def unpublish(conn = %{assigns: %{post: post}}, params) do
    changeset = Ecto.Changeset.change(post, %{published: false})

    case Repo.update(changeset) do
      {:ok, post} ->
        handle_feed_updates(post)
        Cache.delete(post)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, ~p"/admin/posts")

      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, post: post, changeset: changeset)
    end
  end

  defp assign_post(conn = %{params: %{"id" => id}}, _) do
    post = Post |> Repo.get!(id) |> Post.preload_all()
    assign(conn, :post, post)
  end

  defp handle_news_item(%{assigns: %{current_user: logger}}, post) do
    post
    |> PostNewsItem.insert(logger)
    |> NewsQueue.append()
  end

  defp handle_feed_updates(post) do
    if Post.is_published(post) do
      FeedUpdater.queue(post)
    end
  end
end
