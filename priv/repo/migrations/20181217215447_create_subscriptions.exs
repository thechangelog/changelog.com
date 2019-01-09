defmodule Changelog.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :unsubscribed_at, :naive_datetime
      add :person_id, references(:people, on_delete: :delete_all)
      add :podcast_id, references(:podcasts, on_delete: :delete_all)
      add :item_id, references(:news_items, on_delete: :delete_all)
      timestamps()
    end

    create index(:subscriptions, [:person_id])
    create index(:subscriptions, [:podcast_id])
    create index(:subscriptions, [:item_id])
    create index(:subscriptions, [:unsubscribed_at])
  end
end
