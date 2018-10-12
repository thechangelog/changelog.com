defmodule ChangelogWeb.NewsItemCommentController do
  use ChangelogWeb, :controller

  alias Changelog.NewsItemComment

  plug RequireUser, "before creating" when action in [:create]

  def create(conn = %{assigns: %{current_user: user}}, %{"news_item_comment" => comment_params}) do
    comment = %NewsItemComment{author_id: user.id}
    changeset = NewsItemComment.insert_changeset(comment, comment_params)

    case Repo.insert(changeset) do
      {:ok, _comment} ->
        conn
        |> put_flash(:success, "Nice comment!")
        |> redirect(to: referer_or_root_path(conn))
      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: referer_or_root_path(conn))
    end
  end

  def preview(_conn, _params) do
  end

  defp referer_or_root_path(conn) do
    case conn |> get_req_header("referer") |> List.last do
      nil -> root_path(conn, :index)
      referer ->  referer |> URI.parse |> Map.get(:path)
    end
  end

end
