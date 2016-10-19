defmodule Changelog.Slack.GoTimeTest do
  use ExUnit.Case

  alias Changelog.Slack.GoTime

  describe "countdown" do
    test "when there's no upcoming recording" do
      response = GoTime.countdown(nil)
      assert response.text =~ ":sob: There aren't any"
    end

    test "when the upcoming recording is far away" do
      next = Timex.add(Timex.now, Timex.Duration.from_days(9))
      response = GoTime.countdown(%{recorded_at: next})
      assert response.text =~ ":pensive: There's still"
    end

    test "when the upcoming recording is < 24 hours away" do
      next = Timex.add(Timex.now, Timex.Duration.from_hours(14))
      response = GoTime.countdown(%{recorded_at: next})
      assert response.text =~ ":sweat_smile: There's only"
    end

    test "when the upcoming recording is < 2 hours away" do
      next = Timex.add(Timex.now, Timex.Duration.from_hours(1))
      response = GoTime.countdown(%{recorded_at: next})
      assert response.text =~ ":eyes: There's just"
    end

    test "when the upcoming recording is in session" do
      next = Timex.add(Timex.now, Timex.Duration.from_hours(-1))
      response = GoTime.countdown(%{recorded_at: next})
      assert response.text =~ ":tada: It's noOOoOow GO TIME!!"
    end
  end
end
