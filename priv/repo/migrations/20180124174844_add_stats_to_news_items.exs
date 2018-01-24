defmodule Changelog.Repo.Migrations.AddStatsToNewsItems do
  use Ecto.Migration

  def change do
    alter table(:news_items) do
      add :impression_count, :integer, default: 0
      add :click_count, :integer, default: 0
    end
  end
end
