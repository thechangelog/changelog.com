defmodule Changelog.Repo.Migrations.CreateEpisode do
  use Ecto.Migration

  def change do
    create table(:episodes) do
      add :title, :string, null: false
      add :slug, :string, null: false
      add :published, :boolean, default: false
      add :published_at, :naive_datetime
      add :recorded_at, :naive_datetime
      add :duration, :integer
      add :summary, :text
      add :podcast_id, references(:podcasts)

      timestamps()
    end
    create index(:episodes, [:podcast_id])
    create unique_index(:episodes, [:slug, :podcast_id])
    create index(:episodes, [:title])
  end
end
