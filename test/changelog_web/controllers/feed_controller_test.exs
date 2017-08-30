defmodule ChangelogWeb.FeedControllerTest do
  use ChangelogWeb.ConnCase

  test "the sitemap", %{conn: conn} do
    post = insert(:published_post)
    podcast = insert(:podcast)
    episode = insert(:published_episode)
    conn = get(conn, feed_path(conn, :sitemap))
    assert conn.status == 200
    assert conn.resp_body =~ post.slug
    assert conn.resp_body =~ podcast.slug
    assert conn.resp_body =~ episode.slug
  end

  test "the all feed", %{conn: conn} do
    post = insert(:published_post, body: "zomg")
    episode = insert(:published_episode, summary: "zomg")
    conn = get(conn, feed_path(conn, :all))
    assert conn.status == 200
    assert conn.resp_body =~ post.title
    assert conn.resp_body =~ episode.title
    assert conn.resp_body =~ post.body
    assert conn.resp_body =~ episode.summary
  end

  test "the all feed with just titles", %{conn: conn} do
    post = insert(:published_post, body: "zomg")
    episode = insert(:published_episode, summary: "zomg")
    conn = get(conn, feed_path(conn, :all_titles))
    assert conn.status == 200
    assert conn.resp_body =~ post.title
    assert conn.resp_body =~ episode.title
    refute conn.resp_body =~ post.body
    refute conn.resp_body =~ episode.summary
  end

  test "the podcast feed", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)
    conn = get(conn, feed_path(conn, :podcast, p.slug))
    assert conn.status == 200
    assert conn.resp_body =~ e.title
  end

  test "the master podcast feed", %{conn: conn} do
    p1 = insert(:podcast)
    e1 = insert(:published_episode, podcast: p1)
    p2 = insert(:podcast)
    e2 = insert(:published_episode, podcast: p2)

    conn = get(conn, feed_path(conn, :podcast, "master"))
    assert conn.status == 200
    assert conn.resp_body =~ e1.title
    assert conn.resp_body =~ e2.title
  end

  test "the posts feed", %{conn: conn} do
    p1 = insert(:published_post)
    p2 = insert(:post)
    p3 = insert(:published_post)

    conn = get(conn, feed_path(conn, :posts))
    assert conn.status == 200
    assert conn.resp_body =~ p1.title
    refute conn.resp_body =~ p2.title
    assert conn.resp_body =~ p3.title
  end
end
