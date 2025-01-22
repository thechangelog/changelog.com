defmodule ChangelogWeb.EpisodeControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.{NewsItem, Subscription}
  alias ChangelogWeb.TimeView

  @transcript [
    %{"title" => "Host", "body" => "Welcome!"},
    %{"title" => "Guest", "body" => "Thanks!"}
  ]

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

  describe "chapters" do
    test "returns chapters list as json", %{conn: conn} do
      c1 = build(:episode_chapter, starts_at: 0, ends_at: 60, image_url: "img")
      c2 = build(:episode_chapter, starts_at: 60, ends_at: 600)
      c3 = build(:episode_chapter, starts_at: 600, ends_at: 6000, link_url: "link")

      p = insert(:podcast)
      e = insert(:published_episode, podcast: p, audio_chapters: [c1, c2, c3])

      conn = get(conn, Routes.episode_path(conn, :chapters, p.slug, e.slug))

      assert json_response(conn, 200) == %{
               "version" => "1.2.0",
               "chapters" => [
                 %{
                   "title" => c1.title,
                   "startTime" => c1.starts_at,
                   "endTime" => c1.ends_at,
                   "img" => c1.image_url,
                   "number" => 1
                 },
                 %{
                   "title" => c2.title,
                   "startTime" => c2.starts_at,
                   "endTime" => c2.ends_at,
                   "number" => 2
                 },
                 %{
                   "title" => c3.title,
                   "startTime" => c3.starts_at,
                   "endTime" => c3.ends_at,
                   "url" => c3.link_url,
                   "number" => 3
                 }
               ]
             }
    end

    test "returns empty set when episode has no chapters", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:published_episode, podcast: p, audio_chapters: [])

      conn = get(conn, Routes.episode_path(conn, :chapters, p.slug, e.slug))

      assert json_response(conn, 200) == %{
               "version" => "1.2.0",
               "chapters" => []
             }
    end

    test "returns plusplus chapters list as json when specified", %{conn: conn} do
      c1 = build(:episode_chapter, starts_at: 0, ends_at: 60)

      p = insert(:podcast)
      e = insert(:published_episode, podcast: p, plusplus_chapters: [c1])

      conn = get(conn, Routes.episode_path(conn, :chapters, p.slug, e.slug, pp: true))

      assert json_response(conn, 200) == %{
               "version" => "1.2.0",
               "chapters" => [
                 %{
                   "title" => c1.title,
                   "startTime" => c1.starts_at,
                   "endTime" => c1.ends_at,
                   "number" => 1
                 }
               ]
             }
    end

    test "returns empty set when episode has no plusplus chapters", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:published_episode, podcast: p)

      conn = get(conn, Routes.episode_path(conn, :chapters, p.slug, e.slug, pp: true))

      assert json_response(conn, 200) == %{
               "version" => "1.2.0",
               "chapters" => []
             }
    end
  end

  describe "psc chapters" do
    test "returns chapters list as xml", %{conn: conn} do
      c1 = build(:episode_chapter, starts_at: 0, ends_at: 60, image_url: "img")
      c2 = build(:episode_chapter, starts_at: 60, ends_at: 600)
      c3 = build(:episode_chapter, starts_at: 600, ends_at: 6000, link_url: "link")

      p = insert(:podcast)
      e = insert(:published_episode, podcast: p, audio_chapters: [c1, c2, c3])

      conn = get(conn, Routes.episode_path(conn, :psc, p.slug, e.slug))

      assert valid_xml(conn)
    end
  end

  describe "img" do
    test "renders for a regular episode", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:published_episode, podcast: p)

      conn = get(conn, ~p"/#{p.slug}/#{e.slug}/img")

      assert conn.status == 200
    end

    test "renders for a news episode that lacks data", %{conn: conn} do
      p = insert(:podcast, slug: "news")
      e = insert(:published_episode, podcast: p)

      conn = get(conn, ~p"/#{p.slug}/#{e.slug}/img")

      assert conn.status == 200
    end

    test "renders for a news episode that has data", %{conn: conn} do
      p = insert(:podcast, slug: "news")
      e = insert(:published_episode, podcast: p, email_content: "## 🙌 [hello]()")

      conn = get(conn, ~p"/#{p.slug}/#{e.slug}/img")

      assert conn.status == 200
      assert conn.resp_body =~ "hello"
      assert conn.resp_body =~ e.title
    end
  end

  describe "live" do
    test "404 when episode is not recorded live", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:episode, podcast: p, recorded_live: false)

      assert_raise Ecto.NoResultsError, fn ->
        get(conn, ~p"/#{p.slug}/#{e.slug}/live")
      end
    end

    test "404 when episode is recorded live but no youtube id", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:episode, podcast: p, recorded_live: true)

      assert_raise Ecto.NoResultsError, fn ->
        get(conn, ~p"/#{p.slug}/#{e.slug}/live")
      end
    end

    test "redirects when episode is recorded live and has youtube id", %{conn: conn} do
      p = insert(:podcast)
      e = insert(:episode, podcast: p, recorded_live: true, youtube_id: "8675309")

      conn = get(conn, ~p"/#{p.slug}/#{e.slug}/live")

      assert_redirected_to(conn, "https://youtu.be/8675309")
    end
  end

  describe "yt" do
    test "redirects to podcast youtube URL when episodes does not have id", %{conn: conn} do
      p = insert(:podcast, youtube_url: "https://www.youtube.com/changelog")
      e = insert(:episode, podcast: p)

      conn = get(conn, ~p"/#{p.slug}/#{e.slug}/yt")

      assert_redirected_to(conn, "https://www.youtube.com/changelog")
    end

    test "redirects to episode youtube URL when episodes has id", %{conn: conn} do
      p = insert(:podcast, youtube_url: "https://www.youtube.com/changelog")
      e = insert(:episode, podcast: p, youtube_id: "8675309")

      conn = get(conn, ~p"/#{p.slug}/#{e.slug}/yt")

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
        get(conn, ~p"/#{p.slug}/#{e.slug}/live")
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
