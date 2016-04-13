defmodule Changelog.Repo.Migrations.AddItunesUrlToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add :itunes_url, :string
    end
  end
end
