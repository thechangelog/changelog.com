defmodule Changelog.Repo.Migrations.CreateSponsor do
  use Ecto.Migration

  def change do
    create table(:sponsors) do
      add :name, :string, null: false
      add :logo_image, :string
      add :description, :string
      add :github_handle, :string
      add :twitter_handle, :string
      add :website, :string

      timestamps()
    end

    create unique_index(:sponsors, [:name])
  end
end
