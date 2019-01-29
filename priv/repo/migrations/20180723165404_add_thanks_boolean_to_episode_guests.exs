defmodule Changelog.Repo.Migrations.AddThanksBooleanToEpisodeGuests do
  use Ecto.Migration

  def change do
    alter table(:episode_guests) do
      add :thanks, :boolean, default: true
    end
  end
end
