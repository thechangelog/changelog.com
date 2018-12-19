defmodule Changelog.Repo.Migrations.CreateSubscriptions do
  use Ecto.Migration

  def change do
    create table(:subscriptions) do
      add :unsubscribed_at, :naive_datetime
      add :person_id, references(:people)
      add :podcast_id, references(:podcasts)
      add :item_id, references(:news_items)
      timestamps()
    end

    create index(:subscriptions, [:person_id])
    create index(:subscriptions, [:podcast_id])
    create index(:subscriptions, [:item_id])
    create index(:subscriptions, [:unsubscribed_at])
  end
end
