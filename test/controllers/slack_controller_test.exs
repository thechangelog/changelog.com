defmodule Changelog.SlackControllerTest do
  use Changelog.ConnCase

  describe "the Go Time countdown robot" do
    setup do
      {:ok, conn: build_conn(), podcast: insert(:podcast, slug: "gotime")}
    end

    test "it works when no episode is found", %{conn: conn} do
      conn = get(conn, slack_path(conn, :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "There aren't any"
    end

    test "it uses the closest upcoming episode", %{conn: conn, podcast: podcast} do
      near_future = Timex.add(Timex.now, Timex.Duration.from_hours(3))
      far_future = Timex.add(Timex.now, Timex.Duration.from_days(3))
      insert(:episode, podcast: podcast, recorded_at: near_future)
      insert(:episode, podcast: podcast, recorded_at: far_future)
      conn = get(conn, slack_path(conn, :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "There's only"
    end

    test "it uses an episode that is currently recording", %{conn: conn, podcast: podcast} do
      near_past = Timex.subtract(Timex.now, Timex.Duration.from_hours(1))
      insert(:episode, podcast: podcast, recorded_at: near_past)
      conn = get(conn, slack_path(conn, :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "It's noOOoOow GO TIME!!"
    end

    test "it doesn't use non Go Time episodes", %{conn: conn} do
      future = Timex.add(Timex.now, Timex.Duration.from_days(9))
      insert(:episode, recorded_at: future)
      conn = get(conn, slack_path(conn, :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "There aren't any"
    end
  end
end
