defmodule Changelog.Repo.Migrations.CreatePerson do
  use Ecto.Migration

  def change do
    create table(:people) do
      add :name, :string, null: false
      add :email, :string, null: false
      add :handle, :string, null: false
      add :github_handle, :string
      add :twitter_handle, :string
      add :bio, :text
      add :website, :string

      timestamps()
    end

    create unique_index(:people, [:name])
    create unique_index(:people, [:email])
    create unique_index(:people, [:handle])
  end
end
