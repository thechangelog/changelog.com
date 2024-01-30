defmodule Changelog.Repo.Migrations.CreateSponsorReps do
  use Ecto.Migration

  def change do
    create table(:sponsor_reps) do
      add :sponsor_id, references(:sponsors, on_delete: :nothing)
      add :person_id, references(:people, on_delete: :nothing)

      timestamps()
    end

    create unique_index(:sponsor_reps, [:sponsor_id, :person_id])
  end
end
