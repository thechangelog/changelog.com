defmodule Changelog.Slack.CountdownTest do
  use ExUnit.Case

  import ChangelogWeb.TimeView, only: [hours_from_now: 1, hours_ago: 1]
  import Changelog.Factory

  alias Changelog.Slack.Countdown

  describe "live" do
    setup do
      gotime = build(:live_podcast, name: "Go Time")
      jsparty = build(:live_podcast, name: "JS Party")
      [gotime: gotime, jsparty: jsparty]
    end

    test "when there's no upcoming recording" do
      response = Countdown.live(nil)
      assert response.text =~ "No live recordings scheduled"
      assert response.data == nil
    end

    test "when the upcoming recording is far away", context do
      far_away = hours_from_now(24 * 9)
      response = Countdown.live(%{recorded_at: far_away, podcast: context[:gotime], title: ""})
      assert response.text =~ "There's still"
      assert response.data == far_away
    end

    test "when the upcoming recording is < 24 hours away", context do
      less_than_24 = hours_from_now(14)

      response =
        Countdown.live(%{recorded_at: less_than_24, podcast: context[:jsparty], title: ""})

      assert response.text =~ "There's only"
      assert response.data == less_than_24
    end

    test "when the upcoming recording is < 2 hours away", context do
      less_than_2 = hours_from_now(1)

      response =
        Countdown.live(%{recorded_at: less_than_2, podcast: context[:jsparty], title: ""})

      assert response.text =~ "There's just"
      assert response.data == less_than_2
    end

    test "when the upcoming recording is in session and stream is live", context do
      less_than_1 = hours_ago(1)

      response =
        Countdown.live(%{id: 1, recorded_at: less_than_1, podcast: context[:gotime], title: ""})

      assert response.text =~ "It's Go Time!"
      assert response.data == less_than_1
    end
  end
end
