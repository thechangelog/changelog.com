defmodule ChangelogWeb.Admin.EpisodeControllerTest do
  use ChangelogWeb.ConnCase

  import Mock

  alias Changelog.{Episode, EpisodeGuest, Github, NewsItem, ObanWorkers, NewsQueue}

  @valid_attrs %{title: "The one where we win", slug: "181-win"}
  @invalid_attrs %{title: ""}

  setup_with_mocks(
    [
      {Github.Puller, [], [update: fn _, _ -> true end]},
      {Changelog.Merch, [], [create_discount: fn _, _ -> {:ok, %{code: "yup"}} end]},
      {ObanWorkers.AudioUpdater, [], [queue: fn _ -> :ok end]},
      {ObanWorkers.NotesPusher, [], [queue: fn _ -> :ok end]},
      {Changelog.Snap, [], [purge: fn _ -> :ok end]},
      {Craisin.Client, [], [stats: fn _ -> %{"Delivered" => 0, "Opened" => 0} end]}
    ],
    assigns
  ) do
    assigns
  end

  @tag :as_admin
  test "lists all podcast episodes on index", %{conn: conn} do
    p = insert(:podcast)
    e1 = insert(:episode, podcast: p)
    e2 = insert(:episode)

    conn = get(conn, Routes.admin_podcast_episode_path(conn, :index, p.slug))

    assert conn.status == 200
    assert String.contains?(conn.resp_body, p.name)
    assert String.contains?(conn.resp_body, e1.title)
    refute String.contains?(conn.resp_body, e2.title)
  end

  @tag :as_admin
  test "shows episode details on show", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    insert(:episode_stat, episode: e, date: ~D[2016-01-01], downloads: 1.6, uniques: 1)
    insert(:episode_stat, episode: e, date: ~D[2016-01-02], downloads: 320, uniques: 345)

    conn = get(conn, Routes.admin_podcast_episode_path(conn, :show, p.slug, e.slug))

    assert conn.status == 200
    assert String.contains?(conn.resp_body, e.slug)
    assert String.contains?(conn.resp_body, "2")
    assert String.contains?(conn.resp_body, "320")
  end

  @tag :as_admin
  test "renders form to create new podcast episode", %{conn: conn} do
    p = insert(:podcast)
    conn = get(conn, Routes.admin_podcast_episode_path(conn, :new, p.slug))
    assert html_response(conn, 200) =~ ~r/new episode/i
  end

  @tag :as_admin
  test "creates episode and redirects", %{conn: conn} do
    p = insert(:podcast)

    conn =
      post(conn, Routes.admin_podcast_episode_path(conn, :create, p.slug), episode: @valid_attrs)

    e = Repo.one(Episode)

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :edit, p.slug, e.slug)
    assert count(Episode) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    p = insert(:podcast)
    count_before = count(Episode)

    conn =
      post(conn, Routes.admin_podcast_episode_path(conn, :create, p.slug),
        episode: @invalid_attrs
      )

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Episode) == count_before
  end

  @tag :as_admin
  test "renders form to edit episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    conn = get(conn, Routes.admin_podcast_episode_path(conn, :edit, p.slug, e.slug))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates an episode and redirects", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    conn =
      put(conn, Routes.admin_podcast_episode_path(conn, :update, p.slug, e.slug),
        episode: @valid_attrs
      )

    refute called(ObanWorkers.NotesPusher.queue(:_))
    assert called(ObanWorkers.AudioUpdater.queue(:_))
    assert called(Changelog.Snap.purge(:_))
    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode) == 1
  end

  @tag :as_admin
  test "updates a public episode, pushing notes to GitHub", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)

    conn =
      put(conn, Routes.admin_podcast_episode_path(conn, :update, p.slug, e.slug),
        episode: @valid_attrs
      )

    assert called(ObanWorkers.NotesPusher.queue(:_))
    assert called(ObanWorkers.AudioUpdater.queue(:_))
    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
  end

  @tag :as_admin
  test "does not update with invalid attrs", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    conn =
      put(conn, Routes.admin_podcast_episode_path(conn, :update, p.slug, e.slug),
        episode: @invalid_attrs
      )

    refute called(ObanWorkers.NotesPusher.queue(:_))
    refute called(ObanWorkers.AudioUpdater.queue(:_))
    assert html_response(conn, 200) =~ ~r/error/
  end

  @tag :as_admin
  test "deletes a draft episode and redirects", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    conn = delete(conn, Routes.admin_podcast_episode_path(conn, :delete, p.slug, e.slug))

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode) == 0
  end

  @tag :as_admin
  test "doesn't delete a published episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)

    assert_raise Ecto.NoResultsError, fn ->
      delete(conn, Routes.admin_podcast_episode_path(conn, :delete, p.slug, e.slug))
    end
  end

  @tag :as_inserted_admin
  test "publishes an episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)

    conn = post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug))

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published()) == 1
    assert called(ObanWorkers.NotesPusher.queue(:_))
  end

  @tag :as_inserted_admin
  test "schedules an episode for publishing", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p, published_at: Timex.end_of_week(Timex.now()))

    conn = post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug))

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published()) == 0
    assert count(Episode.scheduled()) == 1
    assert called(ObanWorkers.NotesPusher.queue(:_))
  end

  @tag :as_inserted_admin
  test "publishes an episode, optionally setting guest 'thanks' to true", %{conn: conn} do
    g1 = insert(:person)
    g2 = insert(:person)
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)
    eg1 = insert(:episode_guest, episode: e, person: g1, thanks: false)
    eg2 = insert(:episode_guest, episode: e, person: g2, thanks: false)

    conn =
      post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug), %{
        "thanks" => "true"
      })

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published()) == 1
    assert Repo.get(EpisodeGuest, eg1.id).thanks
    assert Repo.get(EpisodeGuest, eg2.id).thanks
    assert called(ObanWorkers.NotesPusher.queue(:_))
  end

  @tag :as_inserted_admin
  test "publishes an episode, optionally not setting guest thanks to 'true'", %{conn: conn} do
    g1 = insert(:person)
    g2 = insert(:person)
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)
    eg1 = insert(:episode_guest, episode: e, person: g1)
    eg2 = insert(:episode_guest, episode: e, person: g2)

    conn = post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug))

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published()) == 1
    refute Repo.get(EpisodeGuest, eg1.id).thanks
    refute Repo.get(EpisodeGuest, eg2.id).thanks
  end

  @tag :as_inserted_admin
  test "publishes an episode, optionally creating a normal news item", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)

    conn =
      post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug), %{
        "news" => "1"
      })

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published()) == 1
    assert count(NewsQueue) == 1
    item = NewsItem |> NewsItem.with_episode(e) |> Repo.one()
    assert item.headline == e.title
    assert item.published_at == e.published_at
  end

  @tag :as_inserted_admin
  test "publishes an episode, optionally creating a feed-only news item", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)

    conn = post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug))

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published()) == 1
    assert count(NewsItem.feed_only()) == 1
    assert count(NewsQueue) == 1
  end

  @tag :as_admin
  test "unpublishes an episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)

    conn = post(conn, Routes.admin_podcast_episode_path(conn, :unpublish, p.slug, e.slug))

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published()) == 0
  end

  @tag :as_admin
  test "fetches and updates transcript", %{conn: conn} do
    p = insert(:podcast, name: "Happy Cast", slug: "happy")
    e = insert(:published_episode, podcast: p, slug: "12")

    conn = post(conn, Routes.admin_podcast_episode_path(conn, :transcript, p.slug, e.slug))

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert called(Github.Puller.update(:_, :_))
  end

  test "requires user auth on all actions", %{conn: conn} do
    podcast = insert(:podcast)

    Enum.each(
      [
        get(conn, Routes.admin_podcast_episode_path(conn, :index, podcast.slug)),
        get(conn, Routes.admin_podcast_episode_path(conn, :new, podcast.slug)),
        get(conn, Routes.admin_podcast_episode_path(conn, :show, podcast.slug, "2")),
        post(conn, Routes.admin_podcast_episode_path(conn, :create, podcast.slug),
          episode: @valid_attrs
        ),
        get(conn, Routes.admin_podcast_episode_path(conn, :edit, podcast.slug, "123")),
        put(conn, Routes.admin_podcast_episode_path(conn, :update, podcast.slug, "123"),
          episode: @valid_attrs
        ),
        delete(conn, Routes.admin_podcast_episode_path(conn, :delete, podcast.slug, "123")),
        post(conn, Routes.admin_podcast_episode_path(conn, :publish, podcast.slug, "123")),
        post(conn, Routes.admin_podcast_episode_path(conn, :unpublish, podcast.slug, "123")),
        post(conn, Routes.admin_podcast_episode_path(conn, :transcript, podcast.slug, "123"))
      ],
      fn conn ->
        assert html_response(conn, 302)
        assert conn.halted
      end
    )
  end
end
