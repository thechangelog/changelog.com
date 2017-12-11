defmodule Changelog.Repo.Migrations.AddTeaserToNewsIssues do
  use Ecto.Migration

  def change do
    alter table(:news_issues) do
      add :teaser, :string
    end
  end
end
