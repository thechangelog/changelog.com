defmodule ChangelogWeb.PostControllerTest do
  use ChangelogWeb.ConnCase

  test "getting the posts index", %{conn: conn} do
    p1 = insert(:published_post)
    i1 = insert(:published_news_item, object_id: "post:#{p1.slug}")
    p2 = insert(:published_post)
    i2 = insert(:published_news_item, object_id: "post:#{p2.slug}")
    unpublished = insert(:post, published: false)
    scheduled = insert(:scheduled_post)

    conn = get(conn, post_path(conn, :index))

    assert conn.status == 200
    assert conn.resp_body =~ i1.headline
    assert conn.resp_body =~ i2.headline
    refute conn.resp_body =~ unpublished.title
    refute conn.resp_body =~ scheduled.title
  end

  test "getting a published post page", %{conn: conn} do
    p = insert(:published_post)
    conn = get(conn, post_path(conn, :show, p.slug))
    assert html_response(conn, 200) =~ p.title
  end

  test "getting a published post page with a news item", %{conn: conn} do
    p = insert(:published_post)
    p |> post_news_item() |> insert()
    conn = get(conn, post_path(conn, :show, p.slug))
    assert html_response(conn, 200) =~ p.title
    assert html_response(conn, 200) =~ "logged by"
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

  test "previewing a post", %{conn: conn} do
    p = insert(:post)

    conn = get(conn, post_path(conn, :preview, p.id))
    assert html_response(conn, 200) =~ p.title
  end
end
