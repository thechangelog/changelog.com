defmodule Changelog.Repo.Migrations.AddLinkedinHandleToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :linkedin_handle, :citext
    end

    create unique_index(:people, [:linkedin_handle])
  end
end
