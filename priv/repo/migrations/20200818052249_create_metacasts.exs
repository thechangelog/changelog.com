defmodule Changelog.Repo.Migrations.CreateMetacasts do
  use Ecto.Migration

  def change do
    create table(:metacasts) do
      add :name, :string, null: false
      add :description, :text
      add :keywords, :string
      add :slug, :string, null: false
      add :is_official, :boolean, null: false
      add :cover, :string

      add :filter_query, :text
      
      timestamps()
    end
  end
end
