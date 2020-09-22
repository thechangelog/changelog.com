defmodule Changelog.Repo.Migrations.MakeCommentAuthorDeleteable do
  use Ecto.Migration

  def change do
    drop constraint(:news_item_comments, "news_item_comments_author_id_fkey")

    alter table(:news_item_comments) do
      modify :author_id, references(:people, on_delete: :nilify_all)
    end
  end
end
