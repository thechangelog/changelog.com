defmodule ChangelogWeb.LiveControllerTest do
  use ChangelogWeb.ConnCase

  import Mock

  alias Changelog.{Episode, Icecast}

  describe "the live index" do
    test "with episodes coming soon", %{conn: conn} do
      episode1 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(24))
      episode2 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(48))

      conn = get(conn, live_path(conn, :index))

      assert html_response(conn, 200) =~ episode1.title
      assert html_response(conn, 200) =~ episode2.title
    end

    test "with episodes live right now", %{conn: conn} do
      episode1 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(1))
      episode2 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(3))

      conn = get(conn, live_path(conn, :index))

      assert html_response(conn, 200) =~ episode1.title
      assert html_response(conn, 200) =~ episode2.title
    end

    test "with no episodes coming soon or live now", %{conn: conn} do
      conn = get(conn, live_path(conn, :index))

      assert html_response(conn, 200) =~ "No scheduled live shows. Check back soon."
    end
  end

  test "getting a live episode page", %{conn: conn} do
    episode = insert(:episode, recorded_live: true, recorded_at: hours_from_now(1))

    conn = get(conn, live_path(conn, :show, Episode.hashid(episode)))

    assert html_response(conn, 200) =~ episode.title
  end

  test "getting a non-live episode page", %{conn: conn} do
    episode = insert(:episode, recorded_live: false, recorded_at: hours_from_now(1))

    assert_raise Ecto.NoResultsError, fn ->
      get(conn, live_path(conn, :show, Episode.hashid(episode)))
    end
  end

  describe "the live status" do
    test "is false when nothing is streaming", %{conn: conn} do
      with_mock(Icecast, [get_stats: fn() -> %Icecast.Stats{} end]) do
        conn = get(conn, live_path(conn, :status))
        response = json_response(conn, 200)
        refute response["streaming"]
        assert response["listeners"] == 0
      end
    end

    test "is true when something is streaming", %{conn: conn} do
      with_mock(Icecast, [get_stats: fn() -> %Icecast.Stats{streaming: true, listeners: 14} end]) do
        conn = get(conn, live_path(conn, :status))
        response = json_response(conn, 200)
        assert response["streaming"]
        assert response["listeners"] == 14
      end
    end
  end
end
