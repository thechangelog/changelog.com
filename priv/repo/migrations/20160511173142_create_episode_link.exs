defmodule Changelog.Repo.Migrations.CreateEpisodeLink do
  use Ecto.Migration

  def change do
    create table(:episode_links) do
      add :title, :string
      add :url, :string, null: false
      add :position, :integer
      add :episode_id, references(:episodes, on_delete: :nothing)

      timestamps
    end

    create index(:episode_links, [:episode_id])
  end
end
