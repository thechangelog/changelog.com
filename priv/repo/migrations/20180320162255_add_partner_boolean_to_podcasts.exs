defmodule Changelog.Repo.Migrations.AddPartnerBooleanToPodcasts do
  use Ecto.Migration

  def change do
    alter table(:podcasts) do
      add :partner, :boolean, default: false
    end

    create index(:podcasts, [:partner])
  end
end
