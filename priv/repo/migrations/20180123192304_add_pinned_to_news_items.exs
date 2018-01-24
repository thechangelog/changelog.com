defmodule Changelog.Repo.Migrations.AddPinnedToNewsItems do
  use Ecto.Migration

  def change do
    alter table(:news_items) do
      add :pinned, :boolean, default: false
    end

    create index(:news_items, [:pinned])
  end
end
