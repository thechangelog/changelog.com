defmodule Changelog.Repo.Migrations.AddRetiredToPodcastHosts do
  use Ecto.Migration

  def change do
    alter table(:podcast_hosts) do
      add :retired, :boolean, default: false
    end

    create index(:podcast_hosts, [:retired])
  end
end
