defmodule Changelog.PodcastControllerTest do
  use Changelog.ConnCase

  test "getting a podcast page" do
    p = create :podcast
    conn = get conn, podcast_path(conn, :show, p.slug)
    assert html_response(conn, 200) =~ p.name
  end

  test "getting a podcast page with a published episode" do
    p = create :podcast
    e = create :published_episode, podcast: p
    conn = get conn, podcast_path(conn, :show, p.slug)
    assert html_response(conn, 200) =~ p.name
    assert String.contains?(conn.resp_body, e.title)
  end

  test "getting a podcast page that doesn't exist" do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, podcast_path(conn, :show, "bad-show")
    end
  end

  test "getting a published podcast episode page" do
    p = create :podcast
    e = create :published_episode, podcast: p
    conn = get conn, episode_path(conn, :episode, p.slug, e.slug)
    assert html_response(conn, 200) =~ e.title
  end

  test "getting a podcast episode page that is not published" do
    p = create :podcast
    e = create :episode, podcast: p

    assert_raise Ecto.NoResultsError, fn ->
      get conn, episode_path(conn, :episode, p.slug, e.slug)
    end
  end

  test "geting a podcast episode page that doesn't exist" do
    p = create :podcast

    assert_raise Ecto.NoResultsError, fn ->
      get conn, episode_path(conn, :episode, p.slug, "bad-episode")
    end
  end

  test "getting a podcast feed" do
    p = create :podcast
    e = create :published_episode, podcast: p
    conn = get conn, podcast_feed_path(conn, :feed, p.slug)
    assert conn.status == 200
    assert conn.resp_body =~ e.title
  end

  test "getting the master feed" do
    p1 = create :podcast
    e1 = create :published_episode, podcast: p1
    p2 = create :podcast
    e2 = create :published_episode, podcast: p2

    conn = get conn, podcast_master_feed_path(conn, :master_feed)
    assert conn.status == 200
    assert conn.resp_body =~ e1.title
    assert conn.resp_body =~ e2.title
  end
end
