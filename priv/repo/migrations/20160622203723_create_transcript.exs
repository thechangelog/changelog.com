defmodule Changelog.Repo.Migrations.CreateTranscript do
  use Ecto.Migration

  def change do
    create table(:transcripts) do
      add :fragments, {:array, :map}
      add :episode_id, references(:episodes, on_delete: :nothing)
      add :raw, :text

      timestamps()
    end

    create unique_index(:transcripts, [:episode_id])
  end
end
