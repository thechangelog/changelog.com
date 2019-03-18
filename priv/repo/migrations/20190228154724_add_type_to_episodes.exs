defmodule Changelog.Repo.Migrations.AddTypeToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :type, :integer, default: 0
    end
  end
end
