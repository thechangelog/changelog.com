defmodule Changelog.Repo.Migrations.CreatePodcast do
  use Ecto.Migration

  def change do
    create table(:podcasts) do
      add :name, :string, null: false
      add :slug, :string, null: false
      add :vanity_domain, :string
      add :description, :text
      add :keywords, :string
      add :twitter_handle, :string

      timestamps
    end

    create unique_index(:podcasts, [:slug])
  end
end
