defmodule Changelog.FeedControllerTest do
  use Changelog.ConnCase

  test "sitemap.xml" do
    post = insert(:post, published: true)
    podcast = insert(:podcast)
    episode = insert(:published_episode)
    conn = get(build_conn, "/sitemap.xml")
    assert conn.status == 200
    assert conn.resp_body =~ post.slug
    assert conn.resp_body =~ podcast.slug
    assert conn.resp_body =~ episode.slug
  end
end
