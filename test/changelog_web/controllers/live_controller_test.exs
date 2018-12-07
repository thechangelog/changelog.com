defmodule ChangelogWeb.LiveControllerTest do
  use ChangelogWeb.ConnCase

  describe "with episodes inside the live window" do
    test "it renders live data when episode is 12 hours from now", %{conn: conn} do
      episode = insert(:episode, recorded_live: true, recorded_at: hours_from_now(12))
      conn = get(conn, live_path(conn, :index))
      assert html_response(conn, 200) =~ episode.title
    end

    test "it renders live data when episode started 1.25 hours ago", %{conn: conn} do
      episode = insert(:episode, recorded_live: true, recorded_at: hours_ago(1.25))
      conn = get(conn, live_path(conn, :index))
      assert html_response(conn, 200) =~ episode.title
    end

    test "it renders the episode that is up next when multiple upcoming", %{conn: conn} do
      episode1 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(8))
      episode2 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(10))
      conn = get(conn, live_path(conn, :index))
      assert html_response(conn, 200) =~ episode1.title
      refute html_response(conn, 200) =~ episode2.title
    end
  end

  describe "with no episodes inside the live window" do
    test "it renders a list of upcoming episodes", %{conn: conn} do
      episode1 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(24))
      episode2 = insert(:episode, recorded_live: true, recorded_at: hours_from_now(48))
      conn = get(conn, live_path(conn, :index))

      assert html_response(conn, 200) =~ episode1.title
      assert html_response(conn, 200) =~ episode2.title
    end

    test "it renders when there are no episodes at all", %{conn: conn} do
      conn = get(conn, live_path(conn, :index))
      assert html_response(conn, 200) =~ "No scheduled shows"
    end
  end
end
