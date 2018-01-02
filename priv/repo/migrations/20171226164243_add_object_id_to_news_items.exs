defmodule Changelog.Repo.Migrations.AddObjectIdToNewsItems do
  use Ecto.Migration

  def change do
    alter table(:news_items) do
      add :object_id, :string
      remove :newsletter
    end

    create index(:news_items, [:object_id])
  end
end
