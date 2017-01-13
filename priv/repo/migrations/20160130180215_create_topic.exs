defmodule Changelog.Repo.Migrations.CreateTopic do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :description, :text
      add :website, :string

      timestamps()
    end

    create index(:topics, [:name])
    create unique_index(:topics, [:slug])
  end
end
