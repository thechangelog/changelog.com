defmodule ChangelogWeb.LiveControllerTest do
  use ChangelogWeb.ConnCase

  alias Changelog.Episode
  alias ChangelogWeb.LiveView

  describe "the live index" do
    test "with episodes coming soon", %{conn: conn} do
      episode1 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(24))
      episode2 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(48))

      conn = get(conn, ~p"/live")

      assert html_response(conn, 200) =~ episode1.title
      assert html_response(conn, 200) =~ episode2.title
    end

    test "with episodes live right now", %{conn: conn} do
      episode1 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(1))
      episode2 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(3))

      conn = get(conn, ~p"/live")

      assert html_response(conn, 200) =~ episode1.title
      assert html_response(conn, 200) =~ episode2.title
    end

    test "with no episodes coming soon or live now", %{conn: conn} do
      conn = get(conn, ~p"/live")

      assert html_response(conn, 200) =~ LiveView.header_for_episode_list([])
    end
  end

  test "getting a live episode page", %{conn: conn} do
    episode = insert(:episode, recorded_live: true, recorded_at: hours_from_now(1))

    conn = get(conn, ~p"/live/#{Episode.hashid(episode)}")

    assert html_response(conn, 200) =~ episode.title
  end

  test "getting a non-live episode page", %{conn: conn} do
    episode = insert(:episode, recorded_live: false, recorded_at: hours_from_now(1))

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, ~p"/live/#{Episode.hashid(episode)}")
    end
  end

  test "getting ical sans podcast slug", %{conn: conn} do
    e1 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(1))
    e2 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(2))

    conn = get(conn, ~p"/live/ical")

    assert conn.resp_body =~ e1.title
    assert conn.resp_body =~ e2.title
  end

  test "getting ical with podcast slug", %{conn: conn} do
    podcast = insert(:podcast)
    e1 = insert(:episode, podcast: podcast, recorded_live: true, recorded_at: hours_from_now(1))
    e2 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(2))

    conn = get(conn, ~p"/live/ical/#{podcast.slug}")

    assert conn.resp_body =~ e1.title
    refute conn.resp_body =~ e2.title
  end

  describe "the live status" do
    test "is false all the time", %{conn: conn} do
      conn = get(conn, ~p"/live/status")
      response = json_response(conn, 200)
      refute response["streaming"]
      assert response["listeners"] == 0
    end
  end
end
