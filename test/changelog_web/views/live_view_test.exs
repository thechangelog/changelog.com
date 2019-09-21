defmodule ChangelogWeb.LiveViewTest do
  use ChangelogWeb.ConnCase, async: true

  alias ChangelogWeb.LiveView
  import ChangelogWeb.TimeView, only: [hours_from_now: 1, hours_ago: 1]

  describe "should_be_live/1" do
    test "is true when episode records inside 2 hour time window" do
      episode = %{recorded_at: hours_ago(1)}
      assert LiveView.should_be_live(episode)
    end

    test "is false when episode records in near future" do
      episode = %{recorded_at: hours_from_now(1)}
      refute LiveView.should_be_live(episode)
    end
  end

  describe "should_be_complete/1" do
    test "is false when episode records in future"do
      episode = %{recorded_at: hours_from_now(12)}
      refute LiveView.should_be_complete(episode)
    end

    test "is false when episode is recording"do
      episode = %{recorded_at: hours_ago(1.5)}
      refute LiveView.should_be_complete(episode)
    end

    test "is true when episode recorded more than 2 hours ago"do
      episode = %{recorded_at: hours_ago(2.25)}
      assert LiveView.should_be_complete(episode)
    end
  end
end
