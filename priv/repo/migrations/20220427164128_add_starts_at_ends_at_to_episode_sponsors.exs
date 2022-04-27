defmodule Changelog.Repo.Migrations.AddStartsAtEndsAtToEpisodeSponsors do
  use Ecto.Migration

  def change do
    alter table(:episode_sponsors) do
      add :starts_at, :float
      add :ends_at, :float
    end
  end
end
