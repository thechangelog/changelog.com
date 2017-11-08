defmodule Changelog.Repo.Migrations.CreateNewsItemTopics do
  use Ecto.Migration

  def change do
    create table(:news_item_topics) do
      add :position, :integer
      add :item_id, references(:news_items)
      add :topic_id, references(:topics)

      timestamps()
    end

    create index(:news_item_topics, [:item_id])
    create index(:news_item_topics, [:topic_id])
    create unique_index(:news_item_topics, [:item_id, :topic_id])
  end
end
