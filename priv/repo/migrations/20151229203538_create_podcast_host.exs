defmodule Changelog.Repo.Migrations.CreatePodcastHost do
  use Ecto.Migration

  def change do
    create table(:podcast_hosts) do
      add :position, :integer
      add :podcast_id, references(:podcasts)
      add :person_id, references(:people)

      timestamps()
    end

    create index(:podcast_hosts, [:podcast_id])
    create index(:podcast_hosts, [:person_id])
    create unique_index(:podcast_hosts, [:podcast_id, :person_id])
  end
end
