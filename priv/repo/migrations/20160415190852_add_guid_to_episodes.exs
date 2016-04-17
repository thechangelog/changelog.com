defmodule Changelog.Repo.Migrations.AddGuidToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :guid, :string
    end
  end
end
