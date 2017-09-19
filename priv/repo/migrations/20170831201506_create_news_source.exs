defmodule Changelog.Repo.Migrations.CreateNewsSource do
  use Ecto.Migration

  def change do
    create table(:news_sources) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :website, :string, null: false
      add :regex, :string
      add :icon, :string

      timestamps()
    end

    create unique_index(:news_sources, [:slug])
  end
end
