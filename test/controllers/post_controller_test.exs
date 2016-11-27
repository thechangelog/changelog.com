defmodule Changelog.PostControllerTest do
  use Changelog.ConnCase

  test "getting the posts index" do
    p1 = insert(:published_post)
    p2 = insert(:published_post)
    unpublished = insert(:post, published: false)
    scheduled = insert(:scheduled_post)

    conn = get(build_conn, post_path(build_conn, :index))

    assert conn.status == 200
    assert conn.resp_body =~ p1.title
    assert conn.resp_body =~ p2.title
    refute conn.resp_body =~ unpublished.title
    refute conn.resp_body =~ scheduled.title
  end

  test "getting a published post page" do
    p = insert(:published_post)
    conn = get(build_conn, post_path(build_conn, :show, p.slug))
    assert html_response(conn, 200) =~ p.title
  end

  test "getting an unpublished post page" do
    p = insert(:post)

    assert_raise Ecto.NoResultsError, fn ->
      get(build_conn, post_path(build_conn, :show, p.slug))
    end
  end

  test "geting a post page that doesn't exist" do
    assert_raise Ecto.NoResultsError, fn ->
      get(build_conn, post_path(build_conn, :show, "bad-post"))
    end
  end

  test "previewing a post when not an admin" do
    p = insert(:post)

    conn = get(build_conn, post_path(build_conn, :preview, p.slug))
    assert conn.halted
  end

  @tag :as_admin
  test "previewing a post when signed in as admin", %{conn: conn} do
    p = insert(:post)

    conn = get(conn, post_path(conn, :preview, p.slug))
    assert html_response(conn, 200) =~ p.title
  end
end
