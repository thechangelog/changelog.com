defmodule Changelog.Repo.Migrations.AddTwitterHandleToNewsSources do
  use Ecto.Migration

  def change do
    alter table(:news_sources) do
      add :twitter_handle, :string
    end

    create unique_index(:news_sources, [:twitter_handle])
  end
end
