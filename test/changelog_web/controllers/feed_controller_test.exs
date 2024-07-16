defmodule ChangelogWeb.FeedControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.NewsItem

  test "the sitemap", %{conn: conn} do
    post = insert(:published_post)
    podcast = insert(:podcast)
    episode = insert(:published_episode)
    topic = insert(:topic)
    news_source = insert(:news_source)
    news_item = insert(:published_news_item)
    insert(:news_item_topic, news_item: news_item, topic: topic)

    conn = get(conn, Routes.feed_path(conn, :sitemap))

    assert conn.status == 200
    assert valid_xml(conn)
    assert conn.resp_body =~ post.slug
    assert conn.resp_body =~ podcast.slug
    assert conn.resp_body =~ episode.slug
    assert conn.resp_body =~ news_source.slug
    assert conn.resp_body =~ topic.slug
    assert conn.resp_body =~ NewsItem.slug(news_item)
  end

  test "the news feed", %{conn: conn} do
    post = insert(:published_post, body: "zomg")
    post |> post_news_item() |> insert()
    episode = insert(:published_episode, summary: "zomg")
    episode |> episode_news_item() |> insert()

    conn = get(conn, Routes.feed_path(conn, :news))

    assert conn.status == 200
    assert valid_xml(conn)
    assert conn.resp_body =~ post.title
    assert conn.resp_body =~ episode.title
    assert conn.resp_body =~ post.body
    assert conn.resp_body =~ episode.summary
  end

  test "the podcast feed", %{conn: conn} do
    p = insert(:podcast, description: "this & that", extended_description: "that & more stuff")
    e = insert(:published_episode, podcast: p)
    insert(:episode_host, episode: e)
    insert(:episode_guest, episode: e)
    insert(:episode_topic, episode: e)
    insert(:episode_sponsor, episode: e)
    e |> episode_news_item() |> insert()

    conn = get(conn, Routes.feed_path(conn, :podcast, p.slug))

    assert conn.status == 200
    assert valid_xml(conn)
    assert conn.resp_body =~ e.title
  end

  test "a podcast feed that doesn't exist", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get(conn, ~p"/comments/feed")
    end
  end

  test "the plusplus feed with incorrect slug doesn't exist", %{conn: conn} do
    Application.put_env(:changelog, :plusplus_slug, "8675309")
    conn = get(conn, Routes.feed_path(conn, :plusplus, "justguessing"))
    assert conn.status == 404
  end

  test "the plusplus feed with correct slug", %{conn: conn} do
    Application.put_env(:changelog, :plusplus_slug, "8675309")

    p1 = insert(:podcast)
    e1 = insert(:published_episode, podcast: p1)
    e1 |> episode_news_item_feed_only() |> insert()

    p2 = insert(:podcast)
    e2 = insert(:published_episode, podcast: p2)
    e2 |> episode_news_item() |> insert()

    conn = get(conn, Routes.feed_path(conn, :plusplus, "8675309"))

    assert conn.status == 200
    assert valid_xml(conn)
    assert conn.resp_body =~ e1.title
    assert conn.resp_body =~ e2.title
  end

  test "the backstage podcast feed doesn't exist", %{conn: conn} do
    insert(:podcast, slug: "backstage")

    conn = get(conn, Routes.feed_path(conn, :podcast, "backstage"))

    assert conn.status == 404
  end

  test "the master podcast feed", %{conn: conn} do
    p1 = insert(:podcast)
    e1 = insert(:published_episode, podcast: p1)
    e1 |> episode_news_item_feed_only() |> insert()

    p2 = insert(:podcast)
    e2 = insert(:published_episode, podcast: p2)
    e2 |> episode_news_item() |> insert()

    conn = get(conn, Routes.feed_path(conn, :podcast, "master"))

    assert conn.status == 200
    assert valid_xml(conn)
    assert conn.resp_body =~ e1.title
    assert conn.resp_body =~ e2.title
  end

  test "a custom feed", %{conn: conn} do
    p1 = insert(:podcast)
    e1 = insert(:published_episode, podcast: p1)
    p2 = insert(:podcast)
    e2 = insert(:published_episode, podcast: p2)
    p3 = insert(:podcast)
    e3 = insert(:published_episode, podcast: p3)

    feed = insert(:feed, podcast_ids: [p1.id, p2.id])

    conn = get(conn, ~p"/feeds/#{feed.slug}")

    assert conn.status == 200
    assert valid_xml(conn)
    assert conn.resp_body =~ e1.title
    assert conn.resp_body =~ e2.title
    refute conn.resp_body =~ e3.title
  end

  test "a custom feed that does not exist", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get(conn, ~p"/feeds/8675309")
    end
  end

  test "the posts feed", %{conn: conn} do
    p1 = insert(:published_post)
    p2 = insert(:post)
    p3 = insert(:published_post)

    conn = get(conn, Routes.feed_path(conn, :posts))

    assert conn.status == 200
    assert valid_xml(conn)
    assert conn.resp_body =~ p1.title
    refute conn.resp_body =~ p2.title
    assert conn.resp_body =~ p3.title
  end
end
