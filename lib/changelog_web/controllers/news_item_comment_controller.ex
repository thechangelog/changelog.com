defmodule ChangelogWeb.NewsItemCommentController do
  use ChangelogWeb, :controller

  alias Changelog.NewsItemComment
  alias Changelog.ObanWorkers.CommentNotifier
  alias ChangelogWeb.NewsItemCommentView
  alias Ecto.Changeset

  plug RequireUser, "before creating or previewing" when action in [:create, :preview]

  def create(conn = %{assigns: %{current_user: user}}, %{"news_item_comment" => comment_params}) do
    comment = %NewsItemComment{author_id: user.id, approved: user.approved}

    # Removed fields that users should not be able to override
    comment_params = Map.drop(comment_params, ["author_id", "approved"])

    changeset = NewsItemComment.insert_changeset(comment, comment_params)

    case Repo.insert(changeset) do
      {:ok, comment} ->
        Task.start_link(fn -> NewsItemComment.refresh_news_item(comment) end)

        # Only send the normal notification out if the user is an approved commenter
        # Else send only to admins for vetting. The notify/1 function validates the state
        # of the comment and sends it to the appropriate recipients.
        CommentNotifier.schedule(comment)

        referer = Plug.Conn.get_req_header(conn, "referer")

        if get_format(conn) == "js" do
          send_to_sentry("new_comment", %{format: "js", referer: referer, comment: comment.id})
          comment = NewsItemComment.preload_all(comment)
          item = comment.news_item
          changeset = item |> build_assoc(:comments) |> NewsItemComment.insert_changeset()

          conn
          |> assign(:item, item)
          |> assign(:comment, comment)
          |> assign(:changeset, changeset)
          |> render("create_success.js")
        else
          send_to_sentry("new_comment", %{format: get_format(conn), referer: referer, comment: comment.id})
          conn
          |> put_flash(:success, random_success_message())
          |> redirect(to: ChangelogWeb.Plug.Conn.referer_or_root_path(conn))
        end

      {:error, _changeset} ->
        if get_format(conn) == "js" do
          conn
          |> put_flash(:error, "Something went wrong")
          |> render("create_failure.js")
        else
          conn
          |> put_flash(:error, "Something went wrong")
          |> redirect(to: ChangelogWeb.Plug.Conn.referer_or_root_path(conn))
        end
    end
  end

  def preview(conn, %{"md" => markdown}) do
    html(conn, NewsItemCommentView.transformed_content(markdown))
  end

  def update(conn, %{"id" => id, "news_item_comment" => %{"content" => updated_content}}) do
    with id <- Changelog.Hashid.decode(id),
         comment = %NewsItemComment{} <- NewsItemComment.get_by_id(id),
         true <- Policies.NewsItemComment.update(conn.assigns.current_user, comment),
         changeset = %Changeset{valid?: true} <- update_comment(comment, updated_content),
         {:ok, comment = %NewsItemComment{}} <- Repo.update(changeset) do
      comment = NewsItemComment.preload_all(comment)
      item = comment.news_item

      conn
      |> put_flash(:success, "Your comment has been updated")
      |> assign(:item, item)
      |> assign(:comment, comment)
      |> assign(:changeset, changeset)
      |> render("create_update.js")
    else
      _error ->
        conn
        |> put_flash(:error, "Unable to update the selected comment!")
        |> put_status(:not_found)
        |> render("create_failure.js")
    end
  end

  def update(conn, _) do
    conn
    |> put_flash(:error, "Unable to update the selected comment!")
    |> put_status(:unprocessable_entity)
    |> render("create_failure.js")
  end

  defp update_comment(comment = %NewsItemComment{}, updated_content) do
    NewsItemComment.update_changeset(comment, %{content: updated_content})
  end

  defp random_success_message do
    [
      "Now that's a solid take! ✊",
      "You tell 'em 💥",
      "That comment is fresh to death 🕺",
      "The hottest of hot takes 🔥",
      "Where do you get all those wonderful words? 🤔",
      "👏👏👏👏👏"
    ]
    |> Enum.random()
  end
end
