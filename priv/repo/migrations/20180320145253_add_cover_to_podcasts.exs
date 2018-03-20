defmodule Changelog.Repo.Migrations.AddCoverToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add :cover, :string
    end
  end
end
