defmodule Changelog.Repo.Migrations.AddTwitterHandleToTopics do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      add :website, :string
      add :twitter_handle, :string
    end

    create unique_index(:topics, [:twitter_handle])
  end
end
