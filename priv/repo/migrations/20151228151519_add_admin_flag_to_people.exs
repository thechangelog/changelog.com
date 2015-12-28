defmodule Changelog.Repo.Migrations.AddAdminFlagToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :admin, :boolean, default: false
    end
  end
end
