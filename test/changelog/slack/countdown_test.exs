defmodule Changelog.Slack.CountdownTest do
  use ExUnit.Case

  import Mock
  import ChangelogWeb.TimeView, only: [hours_from_now: 1, hours_ago: 1]

  alias Changelog.Slack.Countdown
  alias Changelog.Wavestreamer

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

    test "when the upcoming recording is in session and stream is live" do
      response = with_mock Wavestreamer, [is_streaming: fn() -> true end] do
        Countdown.live(%{recorded_at: hours_ago(1), podcast: %{name: "Go Time"}})
      end
      assert response.text =~ ":tada: It's noOOoOow GO TIME!"
    end

    test "when the upcoming recording is in session but stream is not live" do
      response = with_mock Wavestreamer, [is_streaming: fn() -> false end] do
        Countdown.live(%{recorded_at: hours_ago(1), podcast: %{name: "Go Time"}})
      end
      assert response.text =~ ":thinking_face: Go Time _should_ be live"
    end
  end
end
