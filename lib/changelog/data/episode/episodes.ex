defmodule Changelog.Episodes do
  use Changelog.Data

  @calendar_service Application.get_env(:changelog, Changelog.CalendarService)[:adapter]

  alias Changelog.Episode
  alias Changelog.CalendarEvent

  def create(episode_params, podcast) do
    build_assoc(podcast, :episodes)
      |> Episode.preload_all
      |> Episode.admin_changeset(episode_params)
      |> Repo.insert
      |> create_calendar_event
  end

  def update(episode_params, podcast, slug) do
    episode =
      assoc(podcast, :episodes)
      |> Repo.get_by!(slug: slug)
      |> Episode.preload_all

    changeset = Episode.admin_changeset(episode, episode_params)

    case Repo.update(changeset) do
      {:error, changeset} -> {:error, changeset, episode}
      result -> update_calendar_event(result, changeset)
    end
  end

  def delete(slug, podcast) do
    assoc(podcast, :episodes)
      |> Episode.unpublished
      |> Repo.get_by!(slug: slug)
      |> Repo.delete
      |> delete_calendar_event
  end

  defp create_calendar_event({:ok, episode = %Changelog.Episode{recorded_at: recorded_at}}) when not is_nil(recorded_at) do
    calendar_event = build_calendar_event_from(episode)

    case @calendar_service.create(calendar_event) do
      {:ok, event_id} -> Episode.update_calendar_event_id(episode, event_id)
      {:error, _reason} -> {:ok, episode}
    end
  end
  defp create_calendar_event(result), do: result

  defp update_calendar_event({:ok, episode = %Changelog.Episode{calendar_event_id: nil}}, %Ecto.Changeset{changes: %{recorded_at: recorded_at}}) when not is_nil(recorded_at) do
    create_calendar_event({:ok, episode})
  end
  defp update_calendar_event({:ok, episode = %Changelog.Episode{calendar_event_id: event_id}}, _changeset) when is_nil(event_id), do: {:ok, episode}
  defp update_calendar_event({:ok, episode}, changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{recorded_at: recorded_at}} when not is_nil(recorded_at) ->
        update_calendar_event(episode)
      %Ecto.Changeset{changes: %{episode_guests: _guests, episode_hosts: _hosts}} ->
        update_calendar_event(episode)
      %Ecto.Changeset{changes: %{episode_hosts: _hosts}} ->
        update_calendar_event(episode)
      %Ecto.Changeset{changes: %{episode_guests: _guests}} ->
        update_calendar_event(episode)
      %Ecto.Changeset{changes: %{recorded_at: nil}} ->
        @calendar_service.delete(episode.calendar_event_id)
        Episode.remove_calendar_event_id(episode)
      _ ->
        {:ok, episode}
    end
  end

  defp update_calendar_event(episode) do
    @calendar_service.update(episode.calendar_event_id, build_calendar_event_from(episode))
    {:ok, episode}
  end

  defp delete_calendar_event({:ok, episode = %Changelog.Episode{calendar_event_id: calendar_event_id}}) when not is_nil(calendar_event_id) do
    @calendar_service.delete(episode.calendar_event_id)
    {:ok, episode}
  end
  defp delete_calendar_event(result), do: result

  defp build_calendar_event_from(episode) do
    episode
    |> Episode.preload_all
    |> CalendarEvent.build_for
  end
end
