defmodule Changelog.Repo.Migrations.CreateFeedStats do
  use Ecto.Migration

  def change do
    create table(:feed_stats) do
      add :date, :date, null: false
      add :agents, :jsonb
      add :podcast_id, references(:podcasts)
      add :feed_id, references(:feeds)
      timestamps()
    end

    create index(:feed_stats, [:date])
    create index(:feed_stats, [:podcast_id])
    create index(:feed_stats, [:feed_id])
  end
end
