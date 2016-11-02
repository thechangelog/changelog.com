defmodule Changelog.Repo.Migrations.CreateEpisodeStat do
  use Ecto.Migration

  def change do
    create table(:episode_stats) do
      add :date, :date, null: false
      add :episode_bytes, :integer, default: 0
      add :total_bytes, :bigint, default: 0
      add :downloads, :float, default: 0.0
      add :uniques, :integer, default: 0
      add :demographics, :jsonb
      add :episode_id, references(:episodes)
      add :podcast_id, references(:podcasts)
      timestamps
    end

    create index(:episode_stats, [:date])
    create index(:episode_stats, [:episode_id])
    create index(:episode_stats, [:podcast_id])
    create unique_index(:episode_stats, [:date, :episode_id])
  end
end
