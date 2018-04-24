defmodule ChangelogWeb.Admin.GoogleCalendarViewTest do
  use ExUnit.Case, async: true

  alias ChangelogWeb.Admin.GoogleCalendarView

  describe "event_url" do
    test "generate a URL from the event_id and calendar_id" do
      expected_url = "https://www.google.com/calendar/event?eid=RVZFTlRfSUQgQ0FMRU5EQVJfSUQ="

      assert GoogleCalendarView.event_url("EVENT_ID", "CALENDAR_ID") == expected_url
    end
  end
end
