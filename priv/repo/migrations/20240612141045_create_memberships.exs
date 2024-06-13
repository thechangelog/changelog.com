defmodule Changelog.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :subscription_id, :string, null: false
      add :status, :string, null: false
      add :supercast_id, :string
      add :person_id, references(:people)
      add :anonymous, :boolean, default: false
      add :started_at, :naive_datetime, null: false

      timestamps()
    end

    create index(:memberships, [:person_id])
    create index(:memberships, [:status])
    create unique_index(:memberships, [:subscription_id])
  end
end
