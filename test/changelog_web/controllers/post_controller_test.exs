defmodule ChangelogWeb.PostControllerTest do
  use ChangelogWeb.ConnCase

  test "getting the posts index", %{conn: conn} do
    p1 = insert(:published_post)
    p2 = insert(:published_post)
    unpublished = insert(:post, published: false)
    scheduled = insert(:scheduled_post)

    conn = get(conn, post_path(conn, :index))

    assert conn.status == 200
    assert conn.resp_body =~ p1.title
    assert conn.resp_body =~ p2.title
    refute conn.resp_body =~ unpublished.title
    refute conn.resp_body =~ scheduled.title
  end

  test "getting a published post page", %{conn: conn} do
    p = insert(:published_post)
    conn = get(conn, post_path(conn, :show, p.slug))
    assert html_response(conn, 200) =~ p.title
  end

  test "getting an unpublished post page", %{conn: conn} do
    p = insert(:post)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, post_path(conn, :show, p.slug))
    end
  end

  test "geting a post page that doesn't exist", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get(conn, post_path(conn, :show, "bad-post"))
    end
  end

  test "previewing a post when not an admin", %{conn: conn} do
    p = insert(:post)

    conn = get(conn, post_path(conn, :preview, p.slug))
    assert conn.halted
  end

  @tag :as_admin
  test "previewing a post when signed in as admin", %{conn: conn} do
    p = insert(:post)

    conn = get(conn, post_path(conn, :preview, p.slug))
    assert html_response(conn, 200) =~ p.title
  end
end
