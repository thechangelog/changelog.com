defmodule Changelog.Admin.EpisodeControllerTest do
  use Changelog.ConnCase

  alias Changelog.Episode

  @valid_attrs %{title: "The one where we win", slug: "181-win"}
  @invalid_attrs %{title: ""}

  @tag :as_admin
  test "lists all podcast episodes on index", %{conn: conn} do
    p = create :podcast
    e1 = create :episode, podcast: p
    e2 = create :episode

    conn = get conn, admin_podcast_episode_path(conn, :index, p)

    assert html_response(conn, 200) =~ ~r/episodes/i
    assert String.contains?(conn.resp_body, p.name)
    assert String.contains?(conn.resp_body, e1.title)
    refute String.contains?(conn.resp_body, e2.title)
  end

  @tag :as_admin
  test "renders form to create new podcast episode", %{conn: conn} do
    p = create :podcast
    conn = get conn, admin_podcast_episode_path(conn, :new, p)
    assert html_response(conn, 200) =~ ~r/new episode/i
  end

  @tag :as_admin
  test "creates episode and redirects", %{conn: conn} do
    p = create :podcast
    conn = post conn, admin_podcast_episode_path(conn, :create, p), episode: @valid_attrs

    assert redirected_to(conn) == admin_podcast_episode_path(conn, :index, p)
    assert count(Episode) == 1
  end

  @tag :as_admin
  test "does not create with invalid attributes", %{conn: conn} do
    p = create :podcast
    count_before = count(Episode)
    conn = post conn, admin_podcast_episode_path(conn, :create, p), episode: @invalid_attrs

    assert html_response(conn, 200) =~ ~r/error/
    assert count(Episode) == count_before
  end

  @tag :as_admin
  test "renders form to edit episode", %{conn: conn} do
    p = create :podcast
    e = create :episode, podcast: p

    conn = get conn, admin_podcast_episode_path(conn, :edit, p, e)
    assert html_response(conn, 200) =~ ~r/edit/i
  end
end
