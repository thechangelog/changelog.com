defmodule ChangelogWeb.FeedControllerTest do
  use ChangelogWeb.ConnCase

  alias ChangelogWeb.NewsItemView

  test "the sitemap", %{conn: conn} do
    post = insert(:published_post)
    podcast = insert(:podcast)
    episode = insert(:published_episode)
    topic = insert(:topic)
    news_source = insert(:news_source)
    news_item = insert(:published_news_item)
    insert(:news_item_topic, news_item: news_item, topic: topic)

    conn = get(conn, feed_path(conn, :sitemap))

    assert conn.status == 200
    assert conn.resp_body =~ post.slug
    assert conn.resp_body =~ podcast.slug
    assert conn.resp_body =~ episode.slug
    assert conn.resp_body =~ news_source.slug
    assert conn.resp_body =~ topic.slug
    assert conn.resp_body =~ NewsItemView.slug(news_item)
  end

  test "the news feed", %{conn: conn} do
    post = insert(:published_post, body: "zomg")
    post |> post_news_item() |> insert()
    episode = insert(:published_episode, summary: "zomg")
    episode |> episode_news_item() |> insert()

    conn = get(conn, feed_path(conn, :news))

    assert conn.status == 200
    assert conn.resp_body =~ post.title
    assert conn.resp_body =~ episode.title
    assert conn.resp_body =~ post.body
    assert conn.resp_body =~ episode.summary
  end

  test "the news feed with just titles", %{conn: conn} do
    post = insert(:published_post, body: "zomg")
    post |> post_news_item() |> insert
    episode = insert(:published_episode, summary: "zomg")
    episode |> episode_news_item() |> insert

    conn = get(conn, feed_path(conn, :news_titles))

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

  test "the backstage podcast feed doesn't exist", %{conn: conn} do
    insert(:podcast, slug: "backstage")

    conn = get(conn, feed_path(conn, :podcast, "backstage"))

    assert conn.status == 404
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
