defmodule ChangelogWeb.NewsItemCommentControllerTest do
  use ChangelogWeb.ConnCase

  import Mock

  alias Changelog.{NewsItemComment, Notifier}

  @tag :as_user
  test "previewing a comment", %{conn: conn} do
    conn = post(conn, news_item_comment_path(conn, :preview), md: "## Ohai!")
    assert html_response(conn, 200) =~ "<h2>Ohai!</h2>"
  end

  test "does not create with no user", %{conn: conn} do
    item = insert(:published_news_item)
    count_before = count(NewsItemComment)

    conn = post(conn, news_item_comment_path(conn, :create), news_item_comment: %{content: "how dare thee!", item_id: item.id})

    assert redirected_to(conn) == sign_in_path(conn, :new)
    assert count(NewsItemComment) == count_before
  end

  @tag :as_inserted_user
  test "does not create with no item id", %{conn: conn} do
    count_before = count(NewsItemComment)

    conn = post(conn, news_item_comment_path(conn, :create), news_item_comment: %{content: "yickie"})

    assert redirected_to(conn) == root_path(conn, :index)
    assert count(NewsItemComment) == count_before
  end

  @tag :as_inserted_user
  test "creates comment and notifies", %{conn: conn} do
    item = insert(:published_news_item)

    with_mock(Notifier, [notify: fn(_) -> true end]) do
      conn = post(conn, news_item_comment_path(conn, :create), news_item_comment: %{content: "how dare thee!", item_id: item.id})

      assert redirected_to(conn) == root_path(conn, :index)
      assert count(NewsItemComment) == 1
      assert called(Notifier.notify(:_))
    end
  end
end
