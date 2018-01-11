defmodule ChangelogWeb.PodcastControllerTest do
  use ChangelogWeb.ConnCase

  test "getting the podcasts index", %{conn: conn} do
    p1 = insert(:podcast)
    p2 = insert(:podcast)

    conn = get(conn, podcast_path(conn, :index))

    assert conn.status == 200
    assert conn.resp_body =~ p1.name
    assert conn.resp_body =~ p2.name
  end

  test "getting a draft podcast page", %{conn: conn} do
    p = insert(:podcast, status: :draft)
    assert_raise Ecto.NoResultsError, fn ->
      get(conn, podcast_path(conn, :show, p.slug))
    end
  end

  test "getting a podcast page", %{conn: conn} do
    p = insert(:podcast)
    conn = get(conn, podcast_path(conn, :show, p.slug))
    assert html_response(conn, 200) =~ p.name
  end

  test "getting a podcast page with a published episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)
    i = insert(:published_news_item, type: :audio, object_id: "#{p.slug}:#{e.slug}")
    conn = get(conn, podcast_path(conn, :show, p.slug))
    assert html_response(conn, 200) =~ p.name
    assert String.contains?(conn.resp_body, i.headline)
  end

  test "getting a podcast page that doesn't exist", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, podcast_path(conn, :show, "bad-show")
    end
  end
end
