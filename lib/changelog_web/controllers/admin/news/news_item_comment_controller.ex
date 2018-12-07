defmodule ChangelogWeb.Admin.NewsItemCommentController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsItemComment}

  plug :assign_comment when action in [:edit, :update, :delete]
  plug Authorize, [Policies.AdminsOnly, :comment]
  plug :scrub_params, "news_item_comment" when action in [:create, :update]

  def index(conn, params) do
    page =
      NewsItemComment.newest_first()
      |> NewsItemComment.preload_all()
      |> Repo.paginate(params)

    render(conn, :index, comments: page.entries, page: page)
  end

  def edit(conn = %{assigns: %{comment: comment}}, _params) do
    comment = NewsItemComment.preload_all(comment)
    changeset = NewsItemComment.update_changeset(comment)
    render(conn, :edit, changeset: changeset)
  end

  def update(conn = %{assigns: %{comment: comment}}, params = %{"news_item_comment" => comment_params}) do
    comment = NewsItemComment.preload_all(comment)
    changeset = NewsItemComment.update_changeset(comment, comment_params)

    case Repo.update(changeset) do
      {:ok, _comment} ->
        conn
        |> put_flash(:result, "success")
        |> redirect_next(params, admin_news_item_comment_path(conn, :index))
      {:error, changeset} ->
        conn
        |> put_flash(:result, "failure")
        |> render(:edit, comment: comment, changeset: changeset)
    end
  end

  def delete(conn = %{assigns: %{comment: comment}}, _params) do
    Repo.delete!(comment)

    conn
    |> put_flash(:result, "success")
    |> redirect(to: admin_news_item_comment_path(conn, :index))
  end

  defp assign_comment(conn = %{params: %{"id" => id}}, _) do
    comment = Repo.get!(NewsItemComment, id)
    assign(conn, :comment, comment)
  end
end
