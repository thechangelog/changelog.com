defmodule Changelog.Repo.Migrations.AddRefreshedAtToNewsItems do
  use Ecto.Migration

  require Ecto.Query

  def up do
    alter table(:news_items) do
      add :refreshed_at, :naive_datetime
    end

    flush()

    Ecto.Query.from(i in "news_items",
      update: [set: [refreshed_at: i.published_at]])
    |> Changelog.Repo.update_all([])
  end

  def down do
    alter table(:news_items) do
      remove :refreshed_at
    end
  end
end
