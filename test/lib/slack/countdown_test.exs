defmodule Changelog.Slack.CountdownTest do
  use ExUnit.Case
  import Changelog.TimeView, only: [hours_from_now: 1, hours_ago: 1]
  alias Changelog.Slack.Countdown

  describe "live" do
    test "when there's no upcoming recording" do
      response = Countdown.live(nil)
      assert response.text =~ ":sob: There aren't any"
    end

    test "when the upcoming recording is far away" do
      response = Countdown.live(%{recorded_at: hours_from_now(24*9), podcast: %{name: "Go Time"}})
      assert response.text =~ ":pensive: There's still"
    end

    test "when the upcoming recording is < 24 hours away" do
      response = Countdown.live(%{recorded_at: hours_from_now(14), podcast: %{name: "JS Party"}})
      assert response.text =~ ":sweat_smile: There's only"
    end

    test "when the upcoming recording is < 2 hours away" do
      response = Countdown.live(%{recorded_at: hours_from_now(1), podcast: %{name: "Backstage"}})
      assert response.text =~ ":eyes: There's just"
    end

    test "when the upcoming recording is in session" do
      response = Countdown.live(%{recorded_at: hours_ago(1), podcast: %{name: "Go Time"}})
      assert response.text =~ ":tada: It's noOOoOow GO TIME!"
    end
  end
end
