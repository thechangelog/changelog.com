defmodule Changelog.LiveControllerTest do
  use Changelog.ConnCase

  describe "with episodes inside the live window" do
    test "it renders live data when episode is 12 hours from now", %{conn: conn} do
      time = Timex.add(Timex.now, Timex.Duration.from_hours(12))
      episode = insert(:episode, recorded_live: true, recorded_at: time)
      conn = get(conn, live_path(conn, :index))
      assert html_response(conn, 200) =~ episode.title
    end

    test "it renders live data when episode started 2.5 hours ago", %{conn: conn} do
      time = Timex.subtract(Timex.now, Timex.Duration.from_hours(2.5))
      episode = insert(:episode, recorded_live: true, recorded_at: time)
      conn = get(conn, live_path(conn, :index))
      assert html_response(conn, 200) =~ episode.title
    end

    test "it renders the episode that is up next when multiple upcoming", %{conn: conn} do
      time1 = Timex.add(Timex.now, Timex.Duration.from_hours(8))
      time2 = Timex.add(Timex.now, Timex.Duration.from_hours(10))
      episode1 = insert(:episode, recorded_live: true, recorded_at: time1)
      episode2 = insert(:episode, recorded_live: true, recorded_at: time2)
      conn = get(conn, live_path(conn, :index))
      assert html_response(conn, 200) =~ episode1.title
      refute html_response(conn, 200) =~ episode2.title
    end
  end

  describe "with no episodes inside the live window" do
    test "it renders a list of upcoming episodes", %{conn: conn} do
      time1 = Timex.add(Timex.now, Timex.Duration.from_hours(24))
      time2 = Timex.add(Timex.now, Timex.Duration.from_hours(48))
      episode1 = insert(:episode, recorded_live: true, recorded_at: time1)
      episode2 = insert(:episode, recorded_live: true, recorded_at: time2)
      conn = get(conn, live_path(conn, :index))
      assert html_response(conn, 200) =~ "Upcoming"
      assert html_response(conn, 200) =~ episode1.title
      assert html_response(conn, 200) =~ episode2.title
    end

    test "it renders when there are no episodes at all", %{conn: conn} do
      conn = get(conn, live_path(conn, :index))
      assert html_response(conn, 200) =~ "Upcoming"
    end
  end
end
