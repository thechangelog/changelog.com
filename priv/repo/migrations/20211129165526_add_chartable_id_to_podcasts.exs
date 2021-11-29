defmodule Changelog.Repo.Migrations.AddChartableIdToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add :chartable_id, :string
    end
  end
end
