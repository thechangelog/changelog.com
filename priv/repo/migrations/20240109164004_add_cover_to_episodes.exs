defmodule Changelog.Repo.Migrations.AddCoverFieldsToEpisodes do
  use Ecto.Migration

  def change do
    alter table(:episodes) do
      add :cover, :string
    end
  end
end
