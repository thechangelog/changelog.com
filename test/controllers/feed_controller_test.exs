defmodule Changelog.FeedControllerTest do
  use Changelog.ConnCase

  test "the sitemap" do
    post = insert(:published_post)
    podcast = insert(:podcast)
    episode = insert(:published_episode)
    conn = get(build_conn, feed_path(build_conn, :sitemap))
    assert conn.status == 200
    assert conn.resp_body =~ post.slug
    assert conn.resp_body =~ podcast.slug
    assert conn.resp_body =~ episode.slug
  end

  test "the all feed" do
    post = insert(:published_post)
    episode = insert(:published_episode)
    conn = get(build_conn, feed_path(build_conn, :all))
    assert conn.status == 200
    assert conn.resp_body =~ post.slug
    assert conn.resp_body =~ episode.slug
  end

  test "the podcast feed" do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)
    conn = get(build_conn, feed_path(build_conn, :podcast, p.slug))
    assert conn.status == 200
    assert conn.resp_body =~ e.title
  end

  test "the master podcast feed" do
    p1 = insert(:podcast)
    e1 = insert(:published_episode, podcast: p1)
    p2 = insert(:podcast)
    e2 = insert(:published_episode, podcast: p2)

    conn = get(build_conn, feed_path(build_conn, :podcast, "master"))
    assert conn.status == 200
    assert conn.resp_body =~ e1.title
    assert conn.resp_body =~ e2.title
  end

  test "the posts feed" do
    p1 = insert(:published_post)
    p2 = insert(:post)
    p3 = insert(:published_post)

    conn = get(build_conn, feed_path(build_conn, :posts))
    assert conn.status == 200
    assert conn.resp_body =~ p1.title
    refute conn.resp_body =~ p2.title
    assert conn.resp_body =~ p3.title
  end
end
