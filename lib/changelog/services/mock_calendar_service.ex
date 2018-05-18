defmodule Changelog.Services.MockCalendarService do
  alias Changelog.CalendarEvent

  def create(_event = %CalendarEvent{}), do: nil
  def update(_event_id, _event = %CalendarEvent{}), do: nil
  def delete(_event_id), do: nil
end
