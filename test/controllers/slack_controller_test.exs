defmodule Changelog.SlackControllerTest do
  use Changelog.ConnCase

  describe "the Go Time countdown robot" do
    setup do
      {:ok, podcast: insert(:podcast, slug: "gotime")}
    end

    test "it works when no episode is found" do
      conn = get(build_conn(), slack_path(build_conn(), :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "There aren't any"
    end

    test "it uses the closest upcoming episode", %{podcast: podcast} do
      near_future = Timex.add(Timex.now, Timex.Duration.from_hours(3))
      far_future = Timex.add(Timex.now, Timex.Duration.from_days(3))
      insert(:episode, podcast: podcast, recorded_at: near_future)
      insert(:episode, podcast: podcast, recorded_at: far_future)
      conn = get(build_conn(), slack_path(build_conn(), :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "There's only"
    end

    test "it uses an episode that is currently recording", %{podcast: podcast} do
      near_past = Timex.subtract(Timex.now, Timex.Duration.from_hours(1))
      insert(:episode, podcast: podcast, recorded_at: near_past)
      conn = get(build_conn(), slack_path(build_conn(), :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "It's noOOoOow GO TIME!!"
    end

    test "it doesn't use non Go Time episodes" do
      future = Timex.add(Timex.now, Timex.Duration.from_days(9))
      insert(:episode, recorded_at: future)
      conn = get(build_conn(), slack_path(build_conn(), :gotime))
      assert conn.status == 200
      assert conn.resp_body =~ "There aren't any"
    end
  end
end
