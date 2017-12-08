defmodule Changelog.Repo.Migrations.CreateNewsIssues do
  use Ecto.Migration

  def change do
    create table(:news_issues) do
      add :slug, :string, null: false
      add :note, :text
      add :published, :boolean, default: false
      add :published_at, :naive_datetime

      timestamps()
    end

    create unique_index(:news_issues, [:slug])

    create table(:news_issue_items) do
      add :position, :integer
      add :issue_id, references(:news_issues, on_delete: :nothing)
      add :item_id, references(:news_items, on_delete: :nothing)

      timestamps()
    end

    create index(:news_issue_items, [:issue_id])
    create index(:news_issue_items, [:item_id])
    create unique_index(:news_issue_items, [:issue_id, :item_id])

    create table(:news_issue_ads) do
      add :position, :integer
      add :issue_id, references(:news_issues, on_delete: :nothing)
      add :ad_id, references(:news_ads, on_delete: :nothing)

      timestamps()
    end

    create index(:news_issue_ads, [:issue_id])
    create index(:news_issue_ads, [:ad_id])
    create unique_index(:news_issue_ads, [:issue_id, :ad_id])
  end
end
