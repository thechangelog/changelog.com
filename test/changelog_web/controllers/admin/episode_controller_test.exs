defmodule ChangelogWeb.Admin.EpisodeControllerTest do
  use ChangelogWeb.ConnCase

  import Mock

  alias Changelog.{
    Episode,
    EpisodeGuest,
    EpisodeNewsItem,
    Github,
    NewsItem,
    NewsItemTopic,
    ObanWorkers,
    Podcast,
    NewsQueue
  }

  @valid_attrs %{title: "The one where we win", slug: "181-win"}
  @invalid_attrs %{title: ""}

  setup_with_mocks(
    [
      {Github.Puller, [], [update: fn _, _ -> true end]},
      {Changelog.Merch, [], [create_discount: fn _, _ -> {:ok, %{code: "yup"}} end]},
      {ObanWorkers.AudioUpdater, [], [queue: fn _ -> :ok end]},
      {ObanWorkers.NotesPusher, [], [queue: fn _ -> :ok end]},
      {Changelog.Snap, [], [purge: fn _ -> :ok end]},
      {Changelog.TypesenseSearch, [], [update_item: fn _ -> :ok end]},
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
  test "does not publish when first-transition notes push cannot be queued", %{conn: conn} do
    :meck.expect(ObanWorkers.NotesPusher, :queue, fn _ -> {:error, :boom} end)

    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)

    conn = post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug))

    assert html_response(conn, 200) =~ "Edit"
    refute Repo.get!(Episode, e.id).published
    assert Repo.aggregate(NewsItem.with_episode(e), :count) == 0
    assert count(NewsQueue) == 0

    :meck.expect(ObanWorkers.NotesPusher, :queue, fn _ -> :ok end)

    user = conn.assigns.current_user
    conn = conn |> recycle() |> assign(:current_user, user)
    conn = post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug))

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert Repo.get!(Episode, e.id).published
    assert Repo.aggregate(NewsItem.with_episode(e), :count) == 1
    assert count(NewsQueue) == 1
    assert :meck.num_calls(ObanWorkers.NotesPusher, :queue, :_) == 2
  end

  @tag :as_inserted_admin
  test "notes push failure rolls back reconciliation before search or guest thanks side effects",
       %{
         conn: conn
       } do
    :meck.expect(ObanWorkers.NotesPusher, :queue, fn _ -> {:error, :boom} end)

    guest = insert(:person)
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)
    eg = insert(:episode_guest, episode: e, person: guest, thanks: false)

    item =
      insert(:news_item,
        type: :audio,
        status: :published,
        feed_only: true,
        object_id: Episode.object_id(e),
        url: "https://changelog.com/#{p.slug}/#{e.slug}",
        headline: "Old title",
        story: "Old summary",
        published_at: e.published_at
      )

    conn =
      post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug), %{
        "news" => "1",
        "thanks" => "true"
      })

    assert html_response(conn, 200) =~ "Edit"
    refute Repo.get!(Episode, e.id).published
    assert Repo.get!(NewsItem, item.id).feed_only == true
    refute Repo.get!(EpisodeGuest, eg.id).thanks
    refute called(Changelog.TypesenseSearch.update_item(:_))
    refute called(Changelog.Merch.create_discount(:_, :_))

    :meck.expect(ObanWorkers.NotesPusher, :queue, fn _ -> :ok end)

    user = conn.assigns.current_user
    conn = conn |> recycle() |> assign(:current_user, user)

    conn =
      post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug), %{
        "news" => "1",
        "thanks" => "true"
      })

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert Repo.get!(Episode, e.id).published
    assert Repo.get!(NewsItem, item.id).feed_only == false
    assert Repo.get!(EpisodeGuest, eg.id).thanks
    assert called(Changelog.TypesenseSearch.update_item(:_))
    assert called(Changelog.Merch.create_discount(:_, :_))
  end

  @tag :as_inserted_admin
  test "does not publish when guest thanks is requested for a guest without a person", %{
    conn: conn
  } do
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)
    eg = insert(:episode_guest, episode: e, person: nil, person_id: nil, thanks: false)

    conn =
      post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug), %{
        "thanks" => "true"
      })

    response = html_response(conn, 200)

    assert response =~ "Every guest needs a person before thanks can be sent"
    assert response =~ "Missing guest person"
    refute Repo.get!(Episode, e.id).published
    refute Repo.get!(EpisodeGuest, eg.id).thanks
    assert Repo.aggregate(NewsItem.with_episode(e), :count) == 0
    assert count(NewsQueue) == 0
    refute called(ObanWorkers.NotesPusher.queue(:_))
    refute called(Changelog.Merch.create_discount(:_, :_))
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

  @tag :as_inserted_admin
  test "re-publishing reconciles the canonical news item without duplicating queue entries", %{
    conn: conn
  } do
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p, title: "First title", summary: "First summary")

    conn = post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug))

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert Repo.aggregate(NewsItem.with_episode(e), :count) == 1
    assert count(NewsItem.feed_only()) == 1
    assert count(NewsQueue) == 1

    e =
      Repo.get!(Episode, e.id)
      |> Ecto.Changeset.change(title: "Updated title", summary: "Updated summary")
      |> Repo.update!()

    user = conn.assigns.current_user
    conn = conn |> recycle() |> assign(:current_user, user)

    conn =
      post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug), %{
        "news" => "1"
      })

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert Repo.aggregate(NewsItem.with_episode(e), :count) == 1
    assert count(NewsItem.feed_only()) == 0
    assert count(NewsQueue) == 1
    assert :meck.num_calls(ObanWorkers.NotesPusher, :queue, :_) == 1

    item = NewsItem |> NewsItem.with_episode(e) |> Repo.one()
    assert item.headline == "Updated title"
    assert item.story == "Updated summary"
    assert item.feed_only == false
  end

  @tag :as_inserted_admin
  test "re-publishing an already published episode does not create a second news item or queue entry",
       %{
         conn: conn
       } do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)

    insert(:news_item,
      type: :audio,
      status: :published,
      feed_only: true,
      object_id: Episode.object_id(e),
      url: "https://changelog.com/#{p.slug}/#{e.slug}",
      headline: e.title,
      story: e.summary,
      published_at: e.published_at
    )

    conn =
      post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug), %{
        "news" => "1"
      })

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert Repo.aggregate(NewsItem.with_episode(e), :count) == 1
    assert count(NewsQueue) == 0
    refute called(ObanWorkers.NotesPusher.queue(:_))

    item = NewsItem |> NewsItem.with_episode(e) |> Repo.one()
    assert item.feed_only == false
  end

  @tag :as_inserted_admin
  test "unpublish then republish reuses the canonical news item and queue entry", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)

    conn = post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug))

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    item = NewsItem |> NewsItem.with_episode(e) |> Repo.one()
    assert item.feed_only == true
    assert count(NewsQueue) == 1
    assert :meck.num_calls(ObanWorkers.NotesPusher, :queue, :_) == 1

    user = conn.assigns.current_user
    conn = conn |> recycle() |> assign(:current_user, user)
    conn = post(conn, Routes.admin_podcast_episode_path(conn, :unpublish, p.slug, e.slug))

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    refute Repo.get!(Episode, e.id).published
    assert Repo.aggregate(NewsItem.with_episode(e), :count) == 1
    assert count(NewsQueue) == 1

    conn = conn |> recycle() |> assign(:current_user, user)

    conn =
      post(conn, Routes.admin_podcast_episode_path(conn, :publish, p.slug, e.slug), %{
        "news" => "1"
      })

    assert redirected_to(conn) == Routes.admin_podcast_episode_path(conn, :index, p.slug)
    assert Repo.get!(Episode, e.id).published
    assert Repo.aggregate(NewsItem.with_episode(e), :count) == 1
    assert count(NewsQueue) == 1
    assert :meck.num_calls(ObanWorkers.NotesPusher, :queue, :_) == 2

    republished_item = NewsItem |> NewsItem.with_episode(e) |> Repo.one()
    assert republished_item.id == item.id
    assert republished_item.feed_only == false
  end

  test "concurrent publish requests converge on one news item and queue entry" do
    Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
      user = insert(:person, admin: true)
      podcast = insert(:podcast)
      episode = insert(:publishable_episode, podcast: podcast)

      expected_path =
        Routes.admin_podcast_episode_path(ChangelogWeb.Endpoint, :index, podcast.slug)

      publish_path =
        Routes.admin_podcast_episode_path(
          ChangelogWeb.Endpoint,
          :publish,
          podcast.slug,
          episode.slug
        )

      try do
        redirects =
          1..2
          |> Task.async_stream(
            fn _ ->
              :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo, sandbox: false)

              try do
                build_conn()
                |> assign(:current_user, user)
                |> post(publish_path)
                |> redirected_to()
              after
                Ecto.Adapters.SQL.Sandbox.checkin(Repo)
              end
            end,
            max_concurrency: 2,
            timeout: 5_000
          )
          |> Enum.map(fn {:ok, redirect} -> redirect end)

        assert Enum.all?(redirects, &(&1 == expected_path))
        assert Repo.get!(Episode, episode.id).published
        assert Repo.aggregate(NewsItem.with_episode(episode), :count) == 1

        item = NewsItem |> NewsItem.with_episode(episode) |> Repo.one()
        assert Repo.aggregate(from(q in NewsQueue, where: q.item_id == ^item.id), :count) == 1
        assert :meck.num_calls(ObanWorkers.NotesPusher, :queue, :_) == 1
      after
        item_ids =
          episode
          |> NewsItem.with_episode()
          |> Repo.all()
          |> Enum.map(& &1.id)

        Repo.delete_all(from(q in NewsQueue, where: q.item_id in ^item_ids))
        Repo.delete_all(from(t in NewsItemTopic, where: t.item_id in ^item_ids))
        Repo.delete_all(from(i in NewsItem, where: i.id in ^item_ids))
        Repo.delete_all(from(e in Episode, where: e.id == ^episode.id))
        Repo.delete_all(from(p in Podcast, where: p.id == ^podcast.id))
        Repo.delete_all(from(p in Changelog.Person, where: p.id == ^user.id))
      end
    end)
  end

  test "feed-only writer racing admin publish converges on the same canonical news item" do
    Ecto.Adapters.SQL.Sandbox.unboxed_run(Repo, fn ->
      user = insert(:person, admin: true)
      logger = insert(:person)
      podcast = insert(:podcast)
      episode = insert(:published_episode, podcast: podcast)

      expected_path =
        Routes.admin_podcast_episode_path(ChangelogWeb.Endpoint, :index, podcast.slug)

      publish_path =
        Routes.admin_podcast_episode_path(
          ChangelogWeb.Endpoint,
          :publish,
          podcast.slug,
          episode.slug
        )

      admin_publish = fn ->
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo, sandbox: false)

        try do
          redirect =
            build_conn()
            |> assign(:current_user, user)
            |> post(publish_path, %{"news" => "1"})
            |> redirected_to()

          {:admin, redirect}
        after
          Ecto.Adapters.SQL.Sandbox.checkin(Repo)
        end
      end

      feed_only_publish = fn ->
        :ok = Ecto.Adapters.SQL.Sandbox.checkout(Repo, sandbox: false)

        try do
          result =
            case EpisodeNewsItem.insert_published_feed_only_once(episode, logger) do
              {:created, _item} -> :created
              {:existing, _item} -> :existing
            end

          {:feed_only, result}
        after
          Ecto.Adapters.SQL.Sandbox.checkin(Repo)
        end
      end

      try do
        results =
          [admin_publish, feed_only_publish]
          |> Task.async_stream(fn fun -> fun.() end, max_concurrency: 2, timeout: 5_000)
          |> Enum.map(fn {:ok, result} -> result end)

        assert {:admin, expected_path} in results
        assert Repo.get!(Episode, episode.id).published
        assert Repo.aggregate(NewsItem.with_episode(episode), :count) == 1

        item = NewsItem |> NewsItem.with_episode(episode) |> Repo.one()
        assert item.feed_only == false

        queue_count =
          Repo.aggregate(from(q in NewsQueue, where: q.item_id == ^item.id), :count)

        assert queue_count in [0, 1]
        refute called(ObanWorkers.NotesPusher.queue(:_))
      after
        item_ids =
          episode
          |> NewsItem.with_episode()
          |> Repo.all()
          |> Enum.map(& &1.id)

        Repo.delete_all(from(q in NewsQueue, where: q.item_id in ^item_ids))
        Repo.delete_all(from(t in NewsItemTopic, where: t.item_id in ^item_ids))
        Repo.delete_all(from(i in NewsItem, where: i.id in ^item_ids))
        Repo.delete_all(from(e in Episode, where: e.id == ^episode.id))
        Repo.delete_all(from(p in Podcast, where: p.id == ^podcast.id))
        Repo.delete_all(from(p in Changelog.Person, where: p.id in ^[user.id, logger.id]))
      end
    end)
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
