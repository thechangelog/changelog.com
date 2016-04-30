defmodule Changelog.Repo.Migrations.CreateEpisodeSponsor do
  use Ecto.Migration

  def change do
    create table(:episode_sponsors) do
      add :position, :integer
      add :title, :string, null: false
      add :link_url, :string
      add :description, :string
      add :episode_id, references(:episodes, on_delete: :nothing)
      add :sponsor_id, references(:sponsors, on_delete: :nothing)

      timestamps
    end

    create index(:episode_sponsors, [:episode_id])
    create index(:episode_sponsors, [:sponsor_id])
    create unique_index(:episode_sponsors, [:episode_id, :sponsor_id])
  end
end
