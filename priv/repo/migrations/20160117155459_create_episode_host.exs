defmodule Changelog.Repo.Migrations.CreateEpisodeHost do
  use Ecto.Migration

  def change do
    create table(:episode_hosts) do
      add :position, :integer
      add :person_id, references(:people, on_delete: :nothing)
      add :episode_id, references(:episodes, on_delete: :nothing)

      timestamps()
    end

    create index(:episode_hosts, [:person_id])
    create index(:episode_hosts, [:episode_id])
    create unique_index(:episode_hosts, [:episode_id, :person_id])
  end
end
