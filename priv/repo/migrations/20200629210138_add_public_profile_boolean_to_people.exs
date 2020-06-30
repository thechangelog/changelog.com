defmodule Changelog.Repo.Migrations.AddPublicProfileBooleanToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :public_profile, :boolean, default: true
    end

    create index(:people, [:public_profile])
  end
end
