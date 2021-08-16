defmodule Changelog.Repo.Migrations.AddRiversideUrlToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add :riverside_url, :string
    end
  end
end
