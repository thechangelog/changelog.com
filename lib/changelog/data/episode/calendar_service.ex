defmodule Changelog.CalendarService do
  alias Changelog.CalendarEvent

  def create(_event = %CalendarEvent{}), do: {:ok, nil}
  def update(_event_id, _event = %CalendarEvent{}), do: {:ok}
  def delete(_event_id), do: {:ok}
end
