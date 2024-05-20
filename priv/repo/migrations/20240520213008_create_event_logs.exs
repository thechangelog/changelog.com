defmodule Changelog.Repo.Migrations.CreateEventLogs do
  use Ecto.Migration

  def change do
    create table(:event_logs) do
      add :message, :string
      add :caller, :string

      timestamps()
    end
  end
end
