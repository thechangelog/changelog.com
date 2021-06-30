defmodule Changelog.Slack.CountdownTest do
  use ExUnit.Case

  import ChangelogWeb.TimeView, only: [hours_from_now: 1, hours_ago: 1]

  alias Changelog.Slack.Countdown

  describe "live" do
    test "when there's no upcoming recording" do
      response = Countdown.live(nil)
      assert response.text =~ "No live recordings scheduled"
      assert response.data == nil
    end

    test "when the upcoming recording is far away" do
      far_away = hours_from_now(24 * 9)
      response = Countdown.live(%{recorded_at: far_away, podcast: %{name: "Go Time"}, title: ""})
      assert response.text =~ "There's still"
      assert response.data == far_away
    end

    test "when the upcoming recording is < 24 hours away" do
      less_than_24 = hours_from_now(14)

      response =
        Countdown.live(%{recorded_at: less_than_24, podcast: %{name: "JS Party"}, title: ""})

      assert response.text =~ "There's only"
      assert response.data == less_than_24
    end

    test "when the upcoming recording is < 2 hours away" do
      less_than_2 = hours_from_now(1)

      response =
        Countdown.live(%{recorded_at: less_than_2, podcast: %{name: "Backstage"}, title: ""})

      assert response.text =~ "There's just"
      assert response.data == less_than_2
    end

    test "when the upcoming recording is in session and stream is live" do
      less_than_1 = hours_ago(1)

      response =
        Countdown.live(%{id: 1, recorded_at: less_than_1, podcast: %{name: "Go Time"}, title: ""})

      assert response.text =~ "It's Go Time!"
      assert response.data == less_than_1
    end
  end
end
