defmodule Changelog.Repo.Migrations.AddCoverArtToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add :cover_art, :string
    end
  end
end
