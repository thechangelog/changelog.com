defmodule ChangelogWeb.Admin.NewsItemCommentControllerTest do
  use ChangelogWeb.ConnCase
  use Oban.Testing, repo: Changelog.Repo

  import Mock

  alias Changelog.{NewsItemComment, Notifier}
  alias Changelog.ObanWorkers.CommentNotifier

  @tag :as_admin
  test "lists all comments on index", %{conn: conn} do
    c1 = insert(:news_item_comment)
    c2 = insert(:news_item_comment)

    conn = get(conn, Routes.admin_news_item_comment_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Comments/
    assert String.contains?(conn.resp_body, String.slice(c1.content, 0, 5))
    assert String.contains?(conn.resp_body, String.slice(c2.content, 0, 5))
  end

  @tag :as_admin
  test "renders form to edit comment", %{conn: conn} do
    comment = insert(:news_item_comment)

    conn = get(conn, Routes.admin_news_item_comment_path(conn, :edit, comment))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates comment and redirects", %{conn: conn} do
    author = insert(:person)
    comment = insert(:news_item_comment)

    conn =
      put(conn, Routes.admin_news_item_comment_path(conn, :update, comment.id),
        news_item_comment: %{author_id: author.id, content: "bai!"}
      )

    assert redirected_to(conn) == Routes.admin_news_item_comment_path(conn, :index)
    assert Repo.get(NewsItemComment, comment.id).content == "bai!"
  end

  @tag :as_admin
  test "updates comment, redirects, and notified if the comment was approved", %{conn: conn} do
    author = insert(:person)
    comment = insert(:news_item_comment, approved: false)

    with_mock(Notifier, notify: fn %NewsItemComment{approved: true} -> true end) do
      conn =
        put(conn, Routes.admin_news_item_comment_path(conn, :update, comment.id),
          news_item_comment: %{author_id: author.id, content: "bai!", approved: true}
        )

      assert redirected_to(conn) == Routes.admin_news_item_comment_path(conn, :index)
      assert Repo.get(NewsItemComment, comment.id).content == "bai!"
      assert Repo.get(NewsItemComment, comment.id).approved == true

      assert_enqueued([worker: CommentNotifier, args: %{"comment_id" => comment.id}], 100)

      assert %{success: 1, failure: 0} =
               Oban.drain_queue(queue: :email, with_scheduled: true)

      assert called(Notifier.notify(:_))
    end
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    comment = insert(:news_item_comment)

    conn =
      put(conn, Routes.admin_news_item_comment_path(conn, :update, comment.id),
        news_item_comment: %{content: ""}
      )

    assert html_response(conn, 200) =~ ~r/error/
  end

  @tag :as_admin
  test "deletes a comment and redirects", %{conn: conn} do
    comment = insert(:news_item_comment)

    conn = delete(conn, Routes.admin_news_item_comment_path(conn, :delete, comment.id))

    assert redirected_to(conn) == Routes.admin_news_item_comment_path(conn, :index)
    assert count(NewsItemComment) == 0
  end

  test "requires user auth on all actions", %{conn: conn} do
    comment = insert(:news_item_comment)

    Enum.each(
      [
        get(conn, Routes.admin_news_item_comment_path(conn, :index)),
        get(conn, Routes.admin_news_item_comment_path(conn, :edit, comment.id)),
        put(conn, Routes.admin_news_item_comment_path(conn, :update, comment.id),
          news_item_comment: %{}
        ),
        delete(conn, Routes.admin_news_item_comment_path(conn, :delete, comment.id))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
