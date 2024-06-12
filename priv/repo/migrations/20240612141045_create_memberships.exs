defmodule Changelog.Repo.Migrations.CreateMemberships do
  use Ecto.Migration

  def change do
    create table(:memberships) do
      add :subscription_id, :string, null: false
      add :status, :integer, null: false, default: 1
      add :person_id, references(:people)
      add :anonymous, :boolean, default: false

      timestamps()
    end

    create index(:memberships, [:person_id])
    create unique_index(:memberships, [:subscription_id])
  end
end
