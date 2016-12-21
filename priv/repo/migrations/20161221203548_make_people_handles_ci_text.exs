defmodule Changelog.Repo.Migrations.MakePeopleHandlesCiText do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS citext;"

    alter table(:people) do
      modify :email, :citext
      modify :handle, :citext
      modify :github_handle, :citext
      modify :twitter_handle, :citext
    end

    create unique_index(:people, [:github_handle])
    create unique_index(:people, [:twitter_handle])
  end

  def down do
    drop index(:people, [:github_handle])
    drop index(:people, [:twitter_handle])

    alter table(:people) do
      modify :email, :string
      modify :handle, :string
      modify :github_handle, :string
      modify :twitter_handle, :string
    end
  end
end
