defmodule Changelog.Repo.Migrations.AddSubmitterToNewsItems do
  use Ecto.Migration

  def change do
    alter table(:news_items) do
      add :submitter_id, references(:people)
    end

    create index(:news_items, [:submitter_id])
  end
end
