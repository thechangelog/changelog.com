defmodule Changelog.Repo.Migrations.AddSettingsToPeople do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add :settings, :map, default: %{}
    end
  end
end
