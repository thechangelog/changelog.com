defmodule Changelog.PostControllerTest do
  use Changelog.ConnCase

  test "getting a published post page" do
    p = insert(:post, published: true)
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

  # test "getting the posts feed" do
  #   p = insert(:podcast)
  #   conn = get build_conn, podcast_feed_path(conn, :feed, p.slug)
  #   assert conn.status == 200
  # end
end
