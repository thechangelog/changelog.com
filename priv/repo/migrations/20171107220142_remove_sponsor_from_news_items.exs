defmodule Changelog.Repo.Migrations.RemoveSponsorFromNewsItems do
  use Ecto.Migration

  def change do
    drop index(:news_items, [:sponsor_id])
    drop index(:news_items, [:sponsored])
    alter table(:news_items) do
      remove :sponsored
      remove :sponsor_id
    end
  end
end
