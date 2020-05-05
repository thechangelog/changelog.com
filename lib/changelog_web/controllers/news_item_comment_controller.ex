defmodule ChangelogWeb.NewsItemCommentController do
  use ChangelogWeb, :controller

  alias Changelog.{NewsItemComment, Notifier}
  alias ChangelogWeb.NewsItemCommentView

  plug RequireUser, "before creating or previewing" when action in [:create, :preview]

  def create(conn = %{assigns: %{current_user: user}}, %{"news_item_comment" => comment_params}) do
    comment = %NewsItemComment{author_id: user.id}
    # no sneaky sneaky
    comment_params = Map.delete(comment_params, "author_id")
    changeset = NewsItemComment.insert_changeset(comment, comment_params)

    case Repo.insert(changeset) do
      {:ok, comment} ->
        Task.start_link(fn -> NewsItemComment.refresh_news_item(comment) end)
        Task.start_link(fn -> Notifier.notify(comment) end)

        if get_format(conn) == "js" do
          comment = NewsItemComment.preload_all(comment)
          item = comment.news_item
          changeset = item |> build_assoc(:comments) |> NewsItemComment.insert_changeset()

          conn
          |> assign(:item, item)
          |> assign(:comment, comment)
          |> assign(:changeset, changeset)
          |> render("create_success.js")
        else
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
