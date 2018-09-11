defmodule ChangelogWeb.Admin.PostController do
  use ChangelogWeb, :controller

  alias Changelog.{Cache, Post}

  plug :assign_post when action in [:edit, :update, :delete]
  plug Authorize, [Policies.Post, :post]
  plug :scrub_params, "post" when action in [:create, :update]

  def index(conn = %{assigns: %{current_user: me}}, params) do
    page =
      Post.published
      |> Post.newest_first
      |> preload(:author)
      |> Repo.paginate(params)

    scheduled =
      Post.scheduled
      |> Post.newest_first
      |> preload(:author)
      |> Repo.all

    drafts =
      Post.unpublished
      |> Post.authored_by(me)
      |> Post.newest_first(:inserted_at)
      |> preload(:author)
      |> Repo.all

    render(conn, :index, posts: page.entries, scheduled: scheduled, drafts: drafts, page: page)
  end

  def new(conn, _params) do
    changeset = Post.admin_changeset(%Post{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params = %{"post" => post_params}) do
    changeset = Post.admin_changeset(%Post{}, post_params)

    case Repo.insert(changeset) do
      {:ok, post} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_post_path(conn, :edit, post))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render("new.html", changeset: changeset)
    end
  end

  def edit(conn = %{assigns: %{post: post}}, _params) do
    post = Post.preload_all(post)
    changeset = Post.admin_changeset(post)
    render(conn, :edit, post: post, changeset: changeset)
  end

  def update(conn = %{assigns: %{post: post}}, params = %{"post" => post_params}) do
    post = Post.preload_all(post)
    changeset = Post.admin_changeset(post, post_params)

    case Repo.update(changeset) do
      {:ok, post} ->
        Cache.delete(post)

        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_post_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, post: post, changeset: changeset)
    end
  end

  def delete(conn = %{assigns: %{post: post}}, _params) do
    Repo.delete!(post)
    Cache.delete(post)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_post_path(conn, :index))
  end

  defp assign_post(conn = %{params: %{"id" => id}}, _) do
    post = Repo.get!(Post, id) |> Post.preload_all
    assign(conn, :post, post)
  end
end
