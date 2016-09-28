defmodule Changelog.PageControllerTest do
  use Changelog.ConnCase

  test "static pages all render" do
    Enum.each([
      "/",
      "/about",
      "/contact",
      "/films",
      "/membership",
      "/nightly",
      "/nightly/confirmation-pending",
      "/nightly/confirmed",
      "/nightly/unsubscribed",
      "/partnership",
      "/sponsorship",
      "/store",
      "/team",
      "/weekly",
      "/weekly/archive",
      "/weekly/confirmed",
      "/weekly/confirmation-pending",
      "/weekly/unsubscribed",
    ], fn route ->
      conn = get(build_conn, route)
      assert conn.status == 200
    end)
  end

  test "home page includes featured episode" do
    featured = insert :published_episode, featured: true, highlight: "ohai"

    conn = get(build_conn, "/")

    assert html_response(conn, 200) =~ featured.title
  end

  test "getting the feed" do
    podcast = insert(:podcast)
    episode = insert(:published_episode, podcast: podcast)
    post = insert(:published_post)

    conn = get(build_conn, page_path(build_conn, :feed))
    assert conn.status == 200
    assert conn.resp_body =~ episode.title
    assert conn.resp_body =~ post.title
  end
end
