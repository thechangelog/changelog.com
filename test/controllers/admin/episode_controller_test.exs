defmodule Changelog.Admin.EpisodeControllerTest do
  use Changelog.ConnCase

  @valid_attrs %{title: "The one where we win"}
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
end
