defmodule Changelog.Repo.Migrations.AddFeedToNewsSources do
  use Ecto.Migration

  def change do
    alter table(:news_sources) do
      add :feed, :string
    end
  end
end
