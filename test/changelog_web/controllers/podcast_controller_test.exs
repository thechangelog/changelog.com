defmodule ChangelogWeb.PodcastControllerTest do
  use ChangelogWeb.ConnCase

  test "getting the podcasts index", %{conn: conn} do
    p1 = insert(:podcast)
    p2 = insert(:podcast)

    conn = get(conn, Routes.podcast_path(conn, :index))

    assert conn.status == 200
    assert conn.resp_body =~ p1.name
    assert conn.resp_body =~ p2.name
  end

  test "getting a draft podcast page", %{conn: conn} do
    p = insert(:podcast, status: :draft)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, Routes.podcast_path(conn, :show, p.slug))
    end
  end

  test "getting an archived podcast page", %{conn: conn} do
    p = insert(:podcast, status: :archived)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, Routes.podcast_path(conn, :show, p.slug))
    end
  end

  test "getting a podcast page", %{conn: conn} do
    p = insert(:podcast)
    conn = get(conn, Routes.podcast_path(conn, :show, p.slug))
    assert html_response(conn, 200) =~ p.name
  end

  test "getting a podcast's recommended sub-page", %{conn: conn} do
    p = insert(:podcast)
    conn = get(conn, Routes.podcast_path(conn, :recommended, p.slug))
    assert html_response(conn, 200) =~ p.name
  end

  test "getting a podcast page with a published episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)
    i = episode_news_item(e) |> insert()
    conn = get(conn, Routes.podcast_path(conn, :show, p.slug))
    assert html_response(conn, 200) =~ p.name
    assert String.contains?(conn.resp_body, i.headline)
  end

  test "getting a podcast page that doesn't exist", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get(conn, Routes.podcast_path(conn, :show, "bad-show"))
    end
  end

  test "getting a podcast page that is actually an old post", %{conn: conn} do
    p = insert(:published_post)
    conn = get(conn, Routes.podcast_path(conn, :show, p.slug))
    assert redirected_to(conn) == Routes.post_path(conn, :show, p.slug)
  end
end
