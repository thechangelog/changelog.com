defmodule Changelog.Repo.Migrations.AddFeedOnlyToNewsItems do
  use Ecto.Migration

  def change do
    alter table(:news_items) do
      add :feed_only, :boolean, default: false
    end

    create index(:news_items, [:feed_only])
  end
end
