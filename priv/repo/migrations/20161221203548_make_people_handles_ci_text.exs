defmodule Changelog.Repo.Migrations.MakePeopleHandlesCiText do
  use Ecto.Migration

  def up do
    execute "CREATE EXTENSION IF NOT EXISTS citext;"

    drop unique_index(:people, [:email])
    drop unique_index(:people, [:handle])

    alter table(:people) do
      modify :email, :citext
      modify :handle, :citext
      modify :github_handle, :citext
      modify :twitter_handle, :citext
    end

    create unique_index(:people, [:email])
    create unique_index(:people, [:handle])
    create unique_index(:people, [:github_handle])
    create unique_index(:people, [:twitter_handle])
  end

  def down do
    drop index(:people, [:github_handle])
    drop index(:people, [:twitter_handle])
    drop index(:people, [:email])
    drop index(:people, [:handle])

    alter table(:people) do
      modify :email, :string
      modify :handle, :string
      modify :github_handle, :string
      modify :twitter_handle, :string
    end

    create unique_index(:people, [:email])
    create unique_index(:people, [:handle])
  end
end
