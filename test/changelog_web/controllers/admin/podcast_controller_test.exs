defmodule ChangelogWeb.Admin.PodcastControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.Podcast

  @valid_attrs %{name: "Polyglot", slug: "polyglot", status: :published}
  @invalid_attrs %{name: "Polyglot", slug: ""}

  @tag :as_admin
  test "lists all podcasts", %{conn: conn} do
    p1 = insert(:podcast)
    p2 = insert(:podcast)

    conn = get(conn, admin_podcast_path(conn, :index))

    assert html_response(conn, 200) =~ ~r/Podcasts/
    assert String.contains?(conn.resp_body, p1.slug)
    assert String.contains?(conn.resp_body, p2.slug)
  end

  @tag :as_admin
  test "renders form to create new podcast", %{conn: conn} do
    conn = get(conn, admin_podcast_path(conn, :new))
    assert html_response(conn, 200) =~ ~r/new/
  end

  @tag :as_admin
  test "creates podcast and redirects", %{conn: conn} do
    conn = post(conn, admin_podcast_path(conn, :create), podcast: @valid_attrs, next: admin_podcast_path(conn, :index))

    assert redirected_to(conn) == admin_podcast_path(conn, :index)
    assert count(Podcast) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    count_before = count(Podcast)
    conn = post(conn, admin_podcast_path(conn, :create), podcast: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Podcast) == count_before
  end

  @tag :as_admin
  test "renders form to edit podcast", %{conn: conn} do
    podcast = insert(:podcast)

    conn = get(conn, admin_podcast_path(conn, :edit, podcast.slug))
    assert html_response(conn, 200) =~ ~r/edit/i
  end

  @tag :as_admin
  test "updates podcast and redirects", %{conn: conn} do
    podcast = insert(:podcast)

    conn = put(conn, admin_podcast_path(conn, :update, podcast.slug), podcast: @valid_attrs)

    assert redirected_to(conn) == admin_podcast_path(conn, :index)
    assert count(Podcast) == 1
  end

  @tag :as_admin
  test "does not update with invalid attributes", %{conn: conn} do
    podcast = insert(:podcast)
    count_before = count(Podcast)

    conn = put(conn, admin_podcast_path(conn, :update, podcast.slug), podcast: @invalid_attrs)

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Podcast) == count_before
  end

  test "requires user auth on all actions", %{conn: conn} do
    podcast = insert(:podcast)

    Enum.each([
      get(conn, admin_podcast_path(conn, :index)),
      get(conn, admin_podcast_path(conn, :new)),
      post(conn, admin_podcast_path(conn, :create), podcast: @valid_attrs),
      get(conn, admin_podcast_path(conn, :edit, podcast.slug)),
      put(conn, admin_podcast_path(conn, :update, podcast.slug), podcast: @valid_attrs)
    ], fn conn ->
      assert html_response(conn, 302)
      assert conn.halted
    end)
  end
end
