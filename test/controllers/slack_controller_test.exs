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
      insert(:episode, podcast: podcast, recorded_at: hours_from_now(3))
      insert(:episode, podcast: podcast, recorded_at: hours_from_now(24*3))
      conn = get(conn, slack_path(conn, :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "There's only"
    end

    test "it uses an episode that is currently recording", %{conn: conn, podcast: podcast} do
      insert(:episode, podcast: podcast, recorded_at: hours_ago(1))
      conn = get(conn, slack_path(conn, :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "It's noOOoOow GO TIME!!"
    end

    test "it doesn't use non Go Time episodes", %{conn: conn} do
      insert(:episode, recorded_at: hours_from_now(24*9))
      conn = get(conn, slack_path(conn, :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "There aren't any"
    end
  end
end
