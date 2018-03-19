defmodule ChangelogWeb.Admin.GoogleCalendarView do
  use ChangelogWeb, :admin_view

  @google_calendar_id Application.get_env(:changelog, Changelog.CalendarService)[:google_calendar_id]

  def event_url(event_id, calendar_id \\ @google_calendar_id) do
    "https://www.google.com/calendar/event?eid=" <> Base.encode64("#{event_id} #{calendar_id}")
  end
end
