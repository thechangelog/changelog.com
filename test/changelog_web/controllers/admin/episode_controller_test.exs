defmodule ChangelogWeb.Admin.EpisodeControllerTest do
  use ChangelogWeb.ConnCase
  use Bamboo.Test

  import Mock

  alias Changelog.{Episode, Github, NewsItem, NewsQueue}

  @valid_attrs %{title: "The one where we win", slug: "181-win"}
  @invalid_attrs %{title: ""}

  @tag :as_admin
  test "lists all podcast episodes on index", %{conn: conn} do
    p = insert(:podcast)
    e1 = insert(:episode, podcast: p)
    e2 = insert(:episode)

    conn = get(conn, admin_podcast_episode_path(conn, :index, p.slug))

    assert conn.status == 200
    assert String.contains?(conn.resp_body, p.name)
    assert String.contains?(conn.resp_body, e1.title)
    refute String.contains?(conn.resp_body, e2.title)
  end

  @tag :as_admin
  test "shows episode details on show", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    insert(:episode_stat, episode: e, date: ~D[2016-01-01], downloads: 1.4)
    insert(:episode_stat, episode: e, date: ~D[2016-01-02], uniques: 345)

    conn = get(conn, admin_podcast_episode_path(conn, :show, p.slug, e.slug))

    assert conn.status == 200
    assert String.contains?(conn.resp_body, e.slug)
    assert String.contains?(conn.resp_body, "1.4")
    assert String.contains?(conn.resp_body, "345")
  end

  @tag :as_admin
  test "renders form to create new podcast episode", %{conn: conn} do
    p = insert(:podcast)
    conn = get(conn, admin_podcast_episode_path(conn, :new, p.slug))
    assert html_response(conn, 200) =~ ~r/new episode/i
  end

  @tag :as_admin
  test "creates episode and redirects", %{conn: conn} do
    p = insert(:podcast)
    conn = post(conn, admin_podcast_episode_path(conn, :create, p.slug), episode: @valid_attrs)
    e = Repo.one(Episode)

    assert redirected_to(conn) == admin_podcast_episode_path(conn, :edit, p.slug, e.slug)
    assert count(Episode) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    p = insert(:podcast)
    count_before = count(Episode)
    conn = post(conn, admin_podcast_episode_path(conn, :create, p.slug), episode: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Episode) == count_before
  end

  @tag :as_admin
  test "renders form to edit episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    conn = get(conn, admin_podcast_episode_path(conn, :edit, p.slug, e.slug))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates an episode and redirects", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    conn = put(conn, admin_podcast_episode_path(conn, :update, p.slug, e.slug), episode: @valid_attrs)

    assert redirected_to(conn) == admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode) == 1
  end

  @tag :as_admin
  test "does not update with invalid attrs", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    conn = put(conn, admin_podcast_episode_path(conn, :update, p.slug, e.slug), episode: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
  end

  @tag :as_admin
  test "deletes a draft episode and redirects", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:episode, podcast: p)

    conn = delete conn, admin_podcast_episode_path(conn, :delete, p.slug, e.slug)

    assert redirected_to(conn) == admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode) == 0
  end

  @tag :as_admin
  test "doesn't delete a published episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)

    assert_raise Ecto.NoResultsError, fn ->
      delete(conn, admin_podcast_episode_path(conn, :delete, p.slug, e.slug))
    end
  end

  @tag :as_admin
  test "publishes an episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)

    conn = post(conn, admin_podcast_episode_path(conn, :publish, p.slug, e.slug))

    assert redirected_to(conn) == admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published) == 1
  end

  @tag :as_admin
  test "publishes an episode, optionally sending thanks email to guests", %{conn: conn} do
    g1 = insert(:person)
    g2 = insert(:person)
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)
    insert(:episode_guest, episode: e, person: g1)
    insert(:episode_guest, episode: e, person: g2)

    email_opts = %{"from" => "john@doe.com", "reply" => "john@doe.com", "message" => "ohai!"}
    conn = post(conn, admin_podcast_episode_path(conn, :publish, p.slug, e.slug), Map.merge(email_opts, %{"thanks" => "true"}))

    assert redirected_to(conn) == admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published) == 1
    assert_delivered_email ChangelogWeb.Email.guest_thanks(g1, email_opts)
    assert_delivered_email ChangelogWeb.Email.guest_thanks(g2, email_opts)
  end

  @tag :as_inserted_admin
  test "publishes an episode, optionally creating an associated news item", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)

    conn = post(conn, admin_podcast_episode_path(conn, :publish, p.slug, e.slug), %{"news" => "1"})

    assert redirected_to(conn) == admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published) == 1
    assert count(NewsQueue) == 1
    item = NewsItem |> NewsItem.with_episode(e) |> Repo.one
    assert item.headline == e.title
    assert item.published_at == e.published_at
  end

  @tag :as_inserted_admin
  test "publishes an episode, optionally not creating an associated news item", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)

    conn = post(conn, admin_podcast_episode_path(conn, :publish, p.slug, e.slug))

    assert redirected_to(conn) == admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published) == 1
    assert count(NewsItem) == 0
    assert count(NewsQueue) == 0
  end

  @tag :as_admin
  test "publishes an episode, optionally not sending thanks email to guests", %{conn: conn} do
    g1 = insert(:person)
    g2 = insert(:person)
    p = insert(:podcast)
    e = insert(:publishable_episode, podcast: p)
    insert(:episode_guest, episode: e, person: g1)
    insert(:episode_guest, episode: e, person: g2)

    email_opts = %{"from" => "john@doe.com", "reply" => "john@doe.com", "message" => "ohai!"}
    conn = post(conn, admin_podcast_episode_path(conn, :publish, p.slug, e.slug), email_opts)

    assert redirected_to(conn) == admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published) == 1
    refute_delivered_email ChangelogWeb.Email.guest_thanks(g1, email_opts)
    refute_delivered_email ChangelogWeb.Email.guest_thanks(g2, email_opts)
  end

  @tag :as_admin
  test "unpublishes an episode", %{conn: conn} do
    p = insert(:podcast)
    e = insert(:published_episode, podcast: p)

    conn = post(conn, admin_podcast_episode_path(conn, :unpublish, p.slug, e.slug))

    assert redirected_to(conn) == admin_podcast_episode_path(conn, :index, p.slug)
    assert count(Episode.published) == 0
  end

  @tag :as_admin
  test "fetches and updates transcript", %{conn: conn} do
    p = insert(:podcast, name: "Happy Cast", slug: "happy")
    e = insert(:published_episode, podcast: p, slug: "12")

    with_mock Github.Updater, [update: fn(_, _) -> true end] do
      conn = post(conn, admin_podcast_episode_path(conn, :transcript, p.slug, e.slug))

      assert called Github.Updater.update(:_, :_)
      assert redirected_to(conn) == admin_podcast_episode_path(conn, :index, p.slug)
    end
  end

  test "requires user auth on all actions", %{conn: conn} do
    Enum.each([
      get(conn, admin_podcast_episode_path(conn, :index, "1")),
      get(conn, admin_podcast_episode_path(conn, :new, "1")),
      get(conn, admin_podcast_episode_path(conn, :show, "1", "2")),
      post(conn, admin_podcast_episode_path(conn, :create, "1"), episode: @valid_attrs),
      get(conn, admin_podcast_episode_path(conn, :edit, "1", "123")),
      put(conn, admin_podcast_episode_path(conn, :update, "1", "123"), episode: @valid_attrs),
      delete(conn, admin_podcast_episode_path(conn, :delete, "1", "123")),
      post(conn, admin_podcast_episode_path(conn, :publish, "1", "123")),
      post(conn, admin_podcast_episode_path(conn, :unpublish, "1", "123")),
      post(conn, admin_podcast_episode_path(conn, :transcript, "1", "123"))
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
