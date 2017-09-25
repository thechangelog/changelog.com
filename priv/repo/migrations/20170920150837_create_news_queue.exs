defmodule Changelog.Repo.Migrations.CreateNewsQueue do
  use Ecto.Migration

  def change do
    create table(:news_queue) do
      add :item_id, references(:news_items)
      add :position, :float, null: false
    end
  end
end
