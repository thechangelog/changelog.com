defmodule ChangelogWeb.EpisodeControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.{NewsItem, Subscription}
  alias ChangelogWeb.TimeView

  @transcript [%{"title" => "Host", "body" => "Welcome!"}, %{"title" => "Guest", "body" => "Thanks!"}]

  test "getting a published podcast episode page and its embed", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)
    insert(:episode_host, episode: e)
    insert(:episode_host, episode: e)
    insert(:episode_sponsor, episode: e)

    conn = get(conn, Routes.episode_path(conn, :show, p.slug, e.slug))
    assert html_response(conn, 200) =~ e.title

    conn = get(conn, Routes.episode_path(conn, :embed, p.slug, e.slug))
    assert get_resp_header(conn, "x-frame-options") == []
    assert html_response(conn, 200) =~ e.title
  end

  test "getting a published podcast episode page that has a transcript", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p, transcript: @transcript)

    conn = get(conn, Routes.episode_path(conn, :show, p.slug, e.slug))

    assert conn.status == 200
    assert conn.resp_body =~ e.title
    assert conn.resp_body =~ "Welcome!"
    assert conn.resp_body =~ "Thanks!"
  end

  test "getting a scheduled episode's page", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:scheduled_episode, podcast: p)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, Routes.episode_path(conn, :show, p.slug, e.slug))
    end
  end

  test "getting a podcast episode page that is not published", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, Routes.episode_path(conn, :show, p.slug, e.slug))
    end
  end

  test "geting a podcast episode page that doesn't exist", %{conn: conn} do
    p = insert(:podcast)

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, Routes.episode_path(conn, :show, p.slug, "bad-episode"))
    end
  end

  test "previewing a podcast episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)
    insert(:episode_guest, episode: e)
    insert(:episode_guest, episode: e)
    insert(:episode_sponsor, episode: e)

    conn = get(conn, Routes.episode_path(conn, :preview, p.slug, e.slug))
    assert html_response(conn, 200) =~ e.title
  end

  @tag :as_inserted_user
  test "subscribing to a podcast episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)
    conn = post(conn, Routes.episode_path(conn, :subscribe, p.slug, e.slug))
    assert redirected_to(conn) == Routes.episode_path(conn, :show, p.slug, e.slug)
    assert count(Subscription.subscribed()) == 1
  end

  describe "play" do
    test "for published episode", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:published_episode, podcast: p)

      conn = get(conn, Routes.episode_path(conn, :play, p.slug, e.slug))
      assert conn.status == 200
      assert conn.resp_body =~ p.name
      assert conn.resp_body =~ e.title
    end

    test "for published episode with prev and next", %{conn: conn} do
      p = insert(:podcast)
      prev = insert(:published_episode, podcast: p, slug: "1", published_at: hours_ago(3))
      e = insert(:published_episode, podcast: p, slug: "2", published_at: hours_ago(2))
      next = insert(:published_episode, podcast: p, slug: "3", published_at: hours_ago(1))

      conn = get(conn, Routes.episode_path(conn, :play, p.slug, e.slug))
      assert conn.status == 200
      assert conn.resp_body =~ prev.slug
      assert conn.resp_body =~ next.slug
    end
  end

  describe "share" do
    test "for published episode", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:published_episode, podcast: p)

      conn = get(conn, Routes.episode_path(conn, :share, p.slug, e.slug))
      assert conn.status == 200
      assert conn.resp_body =~ e.title
    end
  end

  describe "discuss" do
    test "redirects to news item when episode has one", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:published_episode, podcast: p)
      i = e |> episode_news_item() |> insert()

      conn = get(conn, Routes.episode_path(conn, :discuss, p.slug, e.slug))

      assert redirected_to(conn) == Routes.news_item_path(conn, :show, NewsItem.slug(i))
    end

    test "redirects to episode when episode doesn't have one" do
    end
  end

  describe "transcript" do
    test "when episode has a transcript", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:published_episode, podcast: p, transcript: @transcript)

      conn = get(conn, Routes.episode_path(conn, :transcript, p.slug, e.slug))

      assert conn.status == 200
      assert conn.resp_body =~ "Welcome!"
      assert conn.resp_body =~ "Thanks!"
    end

    test "404 when episode has no transcript", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:published_episode, podcast: p)

      assert_raise Ecto.NoResultsError, fn ->
        get(conn, Routes.episode_path(conn, :transcript, p.slug, e.slug))
      end
    end
  end

  describe "live" do
    test "404 when episode is not recorded live", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:episode, podcast: p, recorded_live: false)

      assert_raise Ecto.NoResultsError, fn ->
        get(conn, Routes.episode_path(conn, :live, p.slug, e.slug))
      end
    end

    test "404 when episode is recorded live but no youtube id", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:episode, podcast: p, recorded_live: true)

      assert_raise Ecto.NoResultsError, fn ->
        get(conn, Routes.episode_path(conn, :live, p.slug, e.slug))
      end
    end

    test "redirects when episode is recorded live and has youtube id", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:episode, podcast: p, recorded_live: true, youtube_id: "8675309")

      conn = get(conn, Routes.episode_path(conn, :live, p.slug, e.slug))

      assert_redirected_to(conn, "https://youtu.be/8675309")
    end
  end

  describe "time" do
    test "404 when episode is not recorded live", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:episode, podcast: p, recorded_live: false)

      assert_raise Ecto.NoResultsError, fn ->
        get(conn, Routes.episode_path(conn, :time, p.slug, e.slug))
      end
    end

    test "404 when episode is recorded live but no recorded_at", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:episode, podcast: p, recorded_at: nil)

      assert_raise Ecto.NoResultsError, fn ->
        get(conn, Routes.episode_path(conn, :live, p.slug, e.slug))
      end
    end

    test "redirects when episode is recorded live and has recorded_at", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:episode, podcast: p, recorded_live: true, recorded_at: hours_from_now(5))

      conn = get(conn, Routes.episode_path(conn, :time, p.slug, e.slug))

      assert_redirected_to(conn, TimeView.time_is_url(e.recorded_at))
    end
  end
end
