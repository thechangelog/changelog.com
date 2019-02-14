defmodule ChangelogWeb.Admin.NewsItemCommentControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.NewsItemComment

  @tag :as_admin
  test "lists all comments on index", %{conn: conn} do
    c1 = insert(:news_item_comment)
    c2 = insert(:news_item_comment)

    conn = get(conn, admin_news_item_comment_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Comments/
    assert String.contains?(conn.resp_body, String.slice(c1.content, 0, 5))
    assert String.contains?(conn.resp_body, String.slice(c2.content, 0, 5))
  end

  @tag :as_admin
  test "renders form to edit comment", %{conn: conn} do
    comment = insert(:news_item_comment)

    conn = get(conn, admin_news_item_comment_path(conn, :edit, comment))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates comment and redirects", %{conn: conn} do
    author = insert(:person)
    comment = insert(:news_item_comment)

    conn = put(conn, admin_news_item_comment_path(conn, :update, comment.id), news_item_comment: %{author_id: author.id, content: "bai!"})

    assert redirected_to(conn) == admin_news_item_comment_path(conn, :index)
    assert Repo.get(NewsItemComment, comment.id).content == "bai!"
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    comment = insert(:news_item_comment)

    conn = put(conn, admin_news_item_comment_path(conn, :update, comment.id), news_item_comment: %{content: ""})

    assert html_response(conn, 200) =~ ~r/error/
  end

  @tag :as_admin
  test "deletes a comment and redirects", %{conn: conn} do
    comment = insert(:news_item_comment)

    conn = delete(conn, admin_news_item_comment_path(conn, :delete, comment.id))

    assert redirected_to(conn) == admin_news_item_comment_path(conn, :index)
    assert count(NewsItemComment) == 0
  end

  test "requires user auth on all actions", %{conn: conn} do
    comment = insert(:news_item_comment)

    Enum.each([
      get(conn, admin_news_item_comment_path(conn, :index)),
      get(conn, admin_news_item_comment_path(conn, :edit, comment.id)),
      put(conn, admin_news_item_comment_path(conn, :update, comment.id), news_item_comment: %{}),
      delete(conn, admin_news_item_comment_path(conn, :delete, comment.id)),
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
