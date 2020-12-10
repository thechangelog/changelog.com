defmodule Changelog.Repo.Migrations.AddApprovedCommentatorColumn do
  use Ecto.Migration

  def change do
    alter table(:people) do
      add(:approved_commentator, :boolean, default: true)
    end

    alter table(:news_item_comments) do
      add(:approved, :boolean, default: true)
    end

    create(index(:news_item_comments, [:approved]))
  end
end
