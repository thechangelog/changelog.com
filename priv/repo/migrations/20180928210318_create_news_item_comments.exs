defmodule Changelog.Repo.Migrations.CreateNewsItemComments do
  use Ecto.Migration

  def change do
    create table(:news_item_comments) do
      add :content, :text, null: false
      add :author_id, references(:people)
      add :item_id, references(:news_items)
      add :parent_id, references(:news_item_comments)
      add :edited_at, :naive_datetime
      add :deleted_at, :naive_datetime
      timestamps()
    end

    create index(:news_item_comments, [:author_id])
    create index(:news_item_comments, [:item_id])
    create index(:news_item_comments, [:parent_id])
  end
end
