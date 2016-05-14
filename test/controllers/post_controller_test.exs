defmodule Changelog.PostControllerTest do
  use Changelog.ConnCase

  test "getting a published post page" do
    p = create :post, published: true
    conn = get conn, post_path(conn, :show, p.slug)
    assert html_response(conn, 200) =~ p.title
  end

  test "getting an unpublished post page" do
    p = create :post

    assert_raise Ecto.NoResultsError, fn ->
      get conn, post_path(conn, :show, p.slug)
    end
  end

  test "geting a post page that doesn't exist" do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, post_path(conn, :show, "bad-post")
    end
  end

  # test "getting the posts feed" do
  #   p = create :podcast
  #   conn = get conn, podcast_feed_path(conn, :feed, p.slug)
  #   assert conn.status == 200
  # end
end
