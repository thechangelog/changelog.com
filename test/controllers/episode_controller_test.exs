defmodule Changelog.EpisodeControllerTest do
  use Changelog.ConnCase

  test "getting a published podcast episode page and its embed" do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)
    insert(:episode_host, episode: e)
    insert(:episode_host, episode: e)
    insert(:episode_sponsor, episode: e)

    conn = get(build_conn, episode_path(build_conn, :show, p.slug, e.slug))
    assert html_response(conn, 200) =~ e.title

    conn = get(build_conn, episode_path(build_conn, :embed, p.slug, e.slug))
    assert html_response(conn, 200) =~ e.title
  end

  test "getting a scheduled episode's page" do
    p = insert(:podcast)
    e = insert(:scheduled_episode, podcast: p)

    assert_raise Ecto.NoResultsError, fn ->
      get(build_conn, episode_path(build_conn, :show, p.slug, e.slug))
    end
  end

  test "getting a podcast episode page that is not published" do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    assert_raise Ecto.NoResultsError, fn ->
      get(build_conn, episode_path(build_conn, :show, p.slug, e.slug))
    end
  end

  test "geting a podcast episode page that doesn't exist" do
    p = insert(:podcast)

    assert_raise Ecto.NoResultsError, fn ->
      get(build_conn, episode_path(build_conn, :show, p.slug, "bad-episode"))
    end
  end

  test "previewing a podcast episode when not an admin" do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    conn = get(build_conn, episode_path(build_conn, :preview, p.slug, e.slug))
    assert conn.halted
  end

  @tag :as_admin
  test "previewing a podcast episode when signed in as admin", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)
    insert(:episode_guest, episode: e)
    insert(:episode_guest, episode: e)
    insert(:episode_sponsor, episode: e)

    conn = get(conn, episode_path(conn, :preview, p.slug, e.slug))
    assert html_response(conn, 200) =~ e.title
  end

  describe "play" do
    test "for unpublished episode" do
      p = insert(:podcast)
      e = insert(:episode, podcast: p)

      assert_raise Ecto.NoResultsError, fn ->
        get(build_conn, episode_path(build_conn, :play, p.slug, e.slug))
      end
    end

    test "for published episode" do
      p = insert(:podcast)
      e = insert(:published_episode, podcast: p)

      conn = get(build_conn, episode_path(build_conn, :play, p.slug, e.slug))
      assert conn.status == 200
      assert conn.resp_body =~ p.name
      assert conn.resp_body =~ e.title
    end

    test "for published episode with prev and next" do
      p = insert(:podcast)
      prev = insert(:published_episode, podcast: p, slug: "1")
      e = insert(:published_episode, podcast: p, slug: "2")
      next = insert(:published_episode, podcast: p, slug: "3")

      conn = get(build_conn, episode_path(build_conn, :play, p.slug, e.slug))
      assert conn.status == 200
      assert conn.resp_body =~ prev.slug
      assert conn.resp_body =~ next.slug
    end
  end
end
