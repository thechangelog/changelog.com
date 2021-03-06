defmodule Changelog.Repo.Migrations.AddingNewsItemPublishedAtIndex do
  use Ecto.Migration

  def change do
    create(index(:news_items, [:published_at]))
  end
end
