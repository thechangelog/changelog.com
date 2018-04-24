defmodule Changelog.Repo.Migrations.AddCalendarEventIdToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add(:calendar_event_id, :string)
    end
  end
end
