defmodule Changelog.Repo.Migrations.AddAgentsToFeeds do
  use Ecto.Migration

  def change do
    alter table(:feeds) do
      add :agents, :jsonb, default: "[]"
    end
  end
end
