defmodule Changelog.PodcastControllerTest do
  use Changelog.ConnCase

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
    conn = get(conn, podcast_path(conn, :show, p.slug))
    assert html_response(conn, 200) =~ p.name
    assert String.contains?(conn.resp_body, e.title)
  end

  test "getting a podcast page that doesn't exist", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, podcast_path(conn, :show, "bad-show")
    end
  end

  test "getting a podcast archive page", %{conn: conn} do
    p = insert(:podcast)
    e1 = insert(:published_episode, podcast: p)
    e2 = insert(:published_episode, podcast: p)
    e3 = insert(:published_episode, podcast: p)
    conn = get(conn, podcast_path(conn, :archive, p.slug))
    assert conn.status == 200
    assert conn.resp_body =~ e1.title
    assert conn.resp_body =~ e2.title
    assert conn.resp_body =~ e3.title
  end
end
