defmodule Changelog.Repo.Migrations.CreateSponsorReps do
  use Ecto.Migration

  def change do
    create table(:sponsor_reps) do
      add :sponsor_id, references(:sponsors, on_delete: :nothing)
      add :rep_id, references(:people, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:sponsor_reps, [:sponsor_id, :rep_id])
  end
end
