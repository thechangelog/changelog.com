defmodule Changelog.Repo.Migrations.AddLiveStuffToPodcastsEpisodes do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add(:recorded_live, :boolean, default: false)
    end

    alter table(:episodes) do
      add(:recorded_live, :boolean, default: false)
    end

    create index(:episodes, [:recorded_live])
  end
end
